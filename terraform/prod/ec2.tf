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
    # ADD NODE TO TAILNET 
    # =============================================================================

    apt-get update -y
    apt-get install -y curl wget unzip make git vim tmux jq
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

    # # =============================================================================
    # # KUBERNETES CLUSTER BOOTSTRAP
    # # Refs:
    # #   - https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
    # #   - https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
    # #   - https://kubernetes.io/docs/setup/production-environment/container-runtimes/
    # #   - https://docs.cilium.io/en/latest/installation/k8s-install-kubeadm/
    # #   - https://containerd.io/releases/#kubernetes-support
    # #   - https://max-pfeiffer.github.io/installing-kubernetes-on-debian-13-trixie.html
    # # =============================================================================

    # K8S_VERSION="1.36"
    # CILIUM_VERSION="1.19.4"

    # # =============================================================================
    # # STEP 1: PREREQUISITES
    # # Ref: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
    # # =============================================================================

    # # 1a. Disable swap - kubelet will fail to start if swap is enabled
    # swapoff -a
    # sed -e '/swap/ s/^#*/#/' -i /etc/fstab
    # systemctl mask swap.target

    # # 1b. Load required kernel modules for container networking
    # # - overlay: required by container runtime for overlay filesystem
    # # - br_netfilter: required for iptables to see bridged traffic
    # cat <<MODULES > /etc/modules-load.d/k8s.conf
    # overlay
    # br_netfilter
    # MODULES
    # modprobe overlay
    # modprobe br_netfilter

    # # 1c. Set required sysctl parameters (persist across reboots)
    # # - net.ipv4.ip_forward: allow packets to be forwarded between interfaces (pod-to-pod traffic)
    # # - net.bridge.bridge-nf-call-iptables: allow iptables to process bridged IPv4 traffic
    # # - net.bridge.bridge-nf-call-ip6tables: same for IPv6
    # cat <<SYSCTL > /etc/sysctl.d/k8s.conf
    # net.ipv4.ip_forward = 1
    # net.bridge.bridge-nf-call-iptables = 1
    # net.bridge.bridge-nf-call-ip6tables = 1
    # SYSCTL
    # sysctl --system

    # # =============================================================================
    # # STEP 2: INSTALL CONTAINER RUNTIME (containerd)
    # # Ref: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
    # # Compat: K8s 1.36 requires containerd >= 2.2.0
    # #         (https://containerd.io/releases/#kubernetes-support)
    # # =============================================================================

    # # 2a. Install containerd from Docker's apt repository (provides containerd >= 2.x for Debian 13)
    # apt-get install -y ca-certificates curl gpg socat conntrack
    # install -m 0755 -d /etc/apt/keyrings
    # curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    # chmod a+r /etc/apt/keyrings/docker.asc
    # echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    #   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    # apt-get update
    # apt-get install -y containerd.io

    # # 2b. Configure containerd
    # # - SystemdCgroup: use systemd as cgroup driver (must match kubelet's driver)
    # # - sandbox_image: pause container image used for pod infrastructure
    # mkdir -p /etc/containerd
    # containerd config default > /etc/containerd/config.toml
    # sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    # sed -i 's|sandbox_image = "registry.k8s.io/pause:.*"|sandbox_image = "registry.k8s.io/pause:3.10"|' /etc/containerd/config.toml
    # systemctl restart containerd

    # # =============================================================================
    # # STEP 3: INSTALL kubeadm, kubelet, kubectl
    # # Ref: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
    # # =============================================================================

    # curl -fsSL "https://pkgs.k8s.io/core:/stable:/v$K8S_VERSION/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    # echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$K8S_VERSION/deb/ /" | \
    #   tee /etc/apt/sources.list.d/kubernetes.list
    # apt-get update
    # apt-get install -y kubelet kubeadm kubectl
    # # Hold packages to prevent accidental upgrades (version skew policy)
    # apt-mark hold kubelet kubeadm kubectl

    # # =============================================================================
    # # STEP 4: INITIALIZE THE CONTROL PLANE
    # # Ref: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node
    # # =============================================================================

    # # 4a. Mount BPF filesystem (required by Cilium for eBPF programs)
    # mount bpffs /sys/fs/bpf -t bpf || true

    # # 4b. Initialize cluster with kube-proxy disabled (Cilium will replace it)
    # # Ref: https://docs.cilium.io/en/latest/installation/k8s-install-kubeadm/#create-the-cluster
    # kubeadm init --skip-phases=addon/kube-proxy

    # # 4c. Configure kubectl access
    # export KUBECONFIG=/etc/kubernetes/admin.conf
    # mkdir ~/.kube
    # cp /etc/kubernetes/admin.conf ~/.kube/config

    # # 4d. Wait for the API server to become ready
    # until kubectl get --raw /readyz &>/dev/null; do sleep 5; done

    # NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

    # # 4e. Allow scheduling on control-plane (single-node cluster)
    # # Ref: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
    # kubectl taint nodes --all node-role.kubernetes.io/control-plane-

    # # =============================================================================
    # # STEP 5: INSTALL POD NETWORK ADD-ON (Cilium with kube-proxy replacement)
    # # Ref: https://docs.cilium.io/en/latest/installation/k8s-install-kubeadm/
    # # =============================================================================

    # # 5a. Install Helm
    # curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
    # chmod 700 get_helm.sh
    # bash get_helm.sh

    # # 5b. Install Cilium via Helm from source chart
    # # - kubeProxyReplacement: Cilium takes over kube-proxy duties via eBPF
    # # - k8sServiceHost/Port: API server address for Cilium to connect to
    # # - operator.replicas=1: single-node cluster only needs one operator
    # # - hubble: observability layer for network flows
    # curl -LO "https://github.com/cilium/cilium/archive/refs/tags/v$CILIUM_VERSION.tar.gz"
    # tar xzf "v$CILIUM_VERSION.tar.gz"

    # helm install cilium "./cilium-$CILIUM_VERSION/install/kubernetes/cilium" \
    #    --namespace kube-system \
    #    --set kubeProxyReplacement=true \
    #    --set k8sServiceHost=$NODE_IP \
    #    --set k8sServicePort=6443 \
    #    --set operator.replicas=1 \
    #    --set hubble.relay.enabled=true \
    #    --set hubble.ui.enabled=true

    # # 5c. Install Cilium CLI for status verification
    # CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
    # CLI_ARCH=amd64
    # curl -L --fail --remote-name-all "https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-linux-$CLI_ARCH.tar.gz{,.sha256sum}"
    # sha256sum --check "cilium-linux-$CLI_ARCH.tar.gz.sha256sum"
    # tar xzvfC "cilium-linux-$CLI_ARCH.tar.gz" /usr/local/bin
    # rm cilium-linux-$CLI_ARCH.tar.gz{,.sha256sum}

    # # 5d. Wait for Cilium to be fully operational (agents + operator + eBPF maps)
    # cilium status --wait

    # # =============================================================================
    # # STEP 6: VERIFY CLUSTER DNS
    # # CoreDNS is deployed by kubeadm and depends on the CNI for pod networking.
    # # With kube-proxy replacement, Cilium must fully program eBPF service maps
    # # before ClusterIP-based services (like CoreDNS at 10.96.0.10) work.
    # # =============================================================================

    # # 6a. Wait for CoreDNS pods to be ready
    # kubectl wait --for=condition=ready -n kube-system pod -l k8s-app=kube-dns --timeout=300s

    # # 6b. Restart CoreDNS to ensure it picks up networking post-Cilium
    # # CoreDNS may have started before Cilium fully programmed eBPF routes
    # # to upstream DNS (VPC resolver at 10.0.0.2), causing cached failures.
    # kubectl rollout restart deployment/coredns -n kube-system
    # kubectl rollout status deployment/coredns -n kube-system --timeout=120s

    # # 6c. Verify DNS resolution actually works end-to-end from a pod
    # # (pod readiness != eBPF datapath readiness for service routing)
    # dns_ok=false
    # for i in $(seq 1 30); do
    #     if kubectl run -i --rm dns-test-$i --image=busybox:1.36 --restart=Never -- nslookup github.com 2>&1 | grep -q "Address"; then
    #         echo "DNS resolution verified on attempt $i"
    #         dns_ok=true
    #         break
    #     fi
    #     echo "DNS not ready yet, retrying in 10s... (attempt $i/30)"
    #     sleep 10
    # done
    # if [ "$dns_ok" != "true" ]; then
    #     echo "ERROR: DNS resolution failed after 30 attempts"
    #     exit 1
    # fi

    # # =============================================================================
    # # STEP 7: GITOPS BOOTSTRAP (FluxCD)
    # # =============================================================================

    # curl -s https://fluxcd.io/install.sh | bash

    # kubectl create namespace doppler-operator-system
    # kubectl create secret generic doppler-token-secret -n doppler-operator-system --from-literal=serviceToken=${var.dp_token}

    # GITHUB_TOKEN=${var.gh_access_token} flux bootstrap github \
    #     --token-auth=true \
    #     --owner=${local.org} \
    #     --repository=infra \
    #     --branch=main \
    #     --path=k8s/overlays/${local.env}/shoot-work-01 \
    #     --read-write-key=true \
    #     --personal=false \
    #     --timeout=10m
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
