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
  ami                         = "ami-0da1f66573556d917"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    
    set -euo pipefail
    # foo
    
    apt-get update -y
    apt-get install -y curl wget unzip make git vim tmux jq
    curl -fsSL https://tailscale.com/install.sh | sh

    API_BASE="https://api.tailscale.com/api/v2"
    TS_TAGS="tag:vm"

    TOKEN=$(curl -sf -d "client_id=${var.ts_oauth_client_id}" -d "client_secret=${var.ts_oauth_client_secret}" "$API_BASE/oauth/token" | jq -r '.access_token')
    if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
        log "ERROR: Failed to obtain OAuth token"
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
        log "ERROR: Failed to create auth key"
        exit 1
    fi

    tailscale up --authkey="$AUTH_KEY" --hostname="${local.org}-${local.env}-work-01" --advertise-tags="$TS_TAGS" --ssh
     
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san ${local.org}-${local.env} --https-listen-port 16443" sh -
    echo "alias kubectl='k3s kubectl'" >> /root/.bashrc
    echo "alias k='k3s kubectl'" >> /root/.bashrc
    
    curl -s https://fluxcd.io/install.sh | sudo bash
    
    KUBECONFIG=/etc/rancher/k3s/k3s.yaml k3s kubectl create namespace doppler-operator-system
    KUBECONFIG=/etc/rancher/k3s/k3s.yaml k3s kubectl create secret generic doppler-token-secret -n doppler-operator-system --from-literal=serviceToken=${var.dp_token}
    
    KUBECONFIG=/etc/rancher/k3s/k3s.yaml GITHUB_TOKEN=${var.gh_access_token} flux bootstrap github \
    	    --token-auth=true \
    	    --owner=${local.org} \
    	    --repository=infra \
    	    --branch=main \
    	    --path=k8s/overlays/${local.env}/shoot-work-01 \
    	    --read-write-key=true \
    	    --personal=false
  EOF

  root_block_device {
    iops        = 3000
    volume_size = 13
    volume_type = "gp3"
  }

  tags = merge(
    {
      Name = "${local.org}-${local.env}"
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
