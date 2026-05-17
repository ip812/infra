resource "aws_security_group" "this" {
  vpc_id = aws_vpc.vpc.id

  timeouts {
    delete = "2m"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_iam_role" "this" {
  name = "role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "this" {
  name = "profile"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  ami                         = "ami-0da1f66573556d917" # Debian 13
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash

    set -euo pipefail

    # =============================================================================
    # STEP 1: CORE DEPENDENCIES 
    # =============================================================================

    apt update -y
    apt install -y curl wget unzip make git vim tmux jq gnupg

    # =============================================================================
    # STEP 1: ADD NODE TO TAILNET
    # =============================================================================

    curl -fsSL https://tailscale.com/install.sh | sh

    API_BASE="https://api.tailscale.com/api/v2"
    TS_TAGS="tag:vm"

    TOKEN=$(curl -sf -d "client_id=${var.ts_oauth_client_id}" -d "client_secret=${var.ts_oauth_client_secret}" "$API_BASE/oauth/token" | jq -r '.access_token')
    if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
        echo "ERROR: Failed to obtain OAuth token"
        exit 1
    fi

    DEVICES=$(curl -sf -H "Authorization: Bearer $TOKEN" "$API_BASE/tailnet/${local.ts_tailnet}/devices")
    DEVICE_ID=$(echo "$DEVICES" | jq -r --arg name "${local.org}-${local.env}-work-01" '.devices[] | select(.hostname == $name) | .id')
    if [ -n "$DEVICE_ID" ]; then
        curl -sf -X DELETE -H "Authorization: Bearer $TOKEN" "$API_BASE/device/$DEVICE_ID" || true
    fi

    TAGS_JSON=$(jq -Rn --arg tags "$TS_TAGS" '$tags | split(",")')
    AUTH_KEY=$(curl -sf -X POST \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        "$API_BASE/tailnet/${local.ts_tailnet}/keys" \
        -d "$(jq -n --argjson tags "$TAGS_JSON" '{
            capabilities: {
                devices: {
                    create: {
                        reusable: false,
                        preauthorized: true,
                        tags: $tags
                    }
                }
            },
            expirySeconds: 3600
        }')" | jq -r '.key')
    if [ -z "$AUTH_KEY" ] || [ "$AUTH_KEY" = "null" ]; then
        echo "ERROR: Failed to create auth key"
        exit 1
    fi

    tailscale up --authkey="$AUTH_KEY" --hostname="${local.org}-${local.env}-work-01" --advertise-tags="$TS_TAGS" --ssh

    # =============================================================================
    # KUBERNETES CLUSTER BOOTSTRAP
    # Refs:
    #   - https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm
    #   - https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm
    #   - https://kubernetes.io/docs/setup/production-environment/container-runtimes
    #   - https://containerd.io/releases/#kubernetes-support
    #   - https://docs.cilium.io/en/latest/installation/k8s-install-kubeadm
    #   - https://max-pfeiffer.github.io/installing-kubernetes-on-debian-13-trixie.html
    # =============================================================================

    K8S_MAJOR="1"
    K8S_MINOR="35"
    K8S_PATCH="5"
    CILIUM_VERSION="1.19.4"

    # =============================================================================
    # STEP 2: CRI (CONTAINERD)
    # =============================================================================

    # Disable swap - kubelet will fail to start if swap is enabled
    # To make the changes permanent adjust the /etc/fstab file
    # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#swap-configuration
    swapoff -a

    # Prepare the kernel for container networking by:
    # - Load needed kernel drivers
    # - Apply proper kernel parameters
    modprobe overlay
    modprobe br_netfilter
    cat <<MODULES > /etc/modules-load.d/k8s.conf
    overlay
    br_netfilter
    MODULES

    cat <<SYSCTL > /etc/sysctl.d/k8s.conf
    net.ipv4.ip_forward = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    SYSCTL
    sysctl --system

    # Install and configure containerd
    # https://docs.docker.com/engine/install/debian/#install-using-the-repository
    apt update -y
    apt install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update -y
    apt install -y containerd.io
    containerd config default | tee /etc/containerd/config.toml
    sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
    systemctl enable containerd
    systemctl restart containerd
    systemctl status containerd

    # =============================================================================
    # STEP 3: HELM 
    # =============================================================================

    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
    apt update
    apt install -y helm

    # =============================================================================
    # STEP 4: KUBEADM + KUBELET + KUBECTL
    # =============================================================================
    curl -fsSL "https://pkgs.k8s.io/core:/stable:/v$K8S_MAJOR.$K8S_MINOR/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$K8S_MAJOR.$K8S_MINOR/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubelet=$K8S_MAJOR.$K8S_MINOR.$K8S_PATCH-1.1 kubeadm=$K8S_MAJOR.$K8S_MINOR.$K8S_PATCH-1.1 kubectl=$K8S_MAJOR.$K8S_MINOR.$K8S_PATCH-1.1
    apt-mark hold kubelet kubeadm kubectl

    # =============================================================================
    # STEP 5: KUBEADM INIT 
    # =============================================================================
    echo "$(hostname -i)  k8s-endpoint" >> /etc/hosts
    kubeadm init --kubernetes-version $K8S_MAJOR.$K8S_MINOR.$K8S_PATCH --control-plane-endpoint k8s-endpoint
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config

    until kubectl get --raw /readyz &>/dev/null; do sleep 5; done
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

    # Allow scheduling on control-plane (single-node cluster)
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-

    # =============================================================================
    # STEP 6: CNI (CILIUM) 
    # =============================================================================

    helm repo add cilium https://helm.cilium.io
    helm install cilium cilium/cilium \
        --version $CILIUM_VERSION \
        --namespace kube-system \
        --set kubeProxyReplacement=true \
        --set operator.replicas=1 \
        --set hubble.relay.enabled=true \
        --set hubble.ui.enabled=true

    CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
    CILIUM_ARCH=$(dpkg --print-architecture)
    curl -L --fail --remote-name-all "https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-linux-$CILIUM_ARCH.tar.gz" "https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-linux-$CILIUM_ARCH.tar.gz.sha256sum"
    sha256sum --check "cilium-linux-$CILIUM_ARCH.tar.gz.sha256sum"
    tar xzvfC "cilium-linux-$CILIUM_ARCH.tar.gz" /usr/local/bin
    rm "cilium-linux-$CILIUM_ARCH.tar.gz" "cilium-linux-$CILIUM_ARCH.tar.gz.sha256sum"

    cilium status --wait

    # =============================================================================
    # STEP 7: BOOTSTRAP WITH FLUXCD
    # =============================================================================

    curl -s https://fluxcd.io/install.sh | bash

    kubectl create namespace doppler-operator-system
    kubectl create secret generic doppler-token-secret -n doppler-operator-system --from-literal=serviceToken=${var.dp_token}

    GITHUB_TOKEN=${var.gh_access_token} flux bootstrap github \
        --token-auth=true \
        --owner=${local.org} \
        --repository=infra \
        --branch=main \
        --path=k8s/overlays/${local.env}/shoot-work-01 \
        --read-write-key=true \
        --personal=false \
        --timeout=10m
  EOF

  root_block_device {
    iops        = 3000
    volume_size = 13
    volume_type = "gp3"
  }

  tags = merge(
    {
      Name = "${local.org}-${local.env}-work-01"
    },
    local.default_tags
  )

  lifecycle {
    replace_triggered_by = [
      aws_security_group.this.name,
      aws_security_group.this.egress.security_group_rule_id
    ]
  }
}
