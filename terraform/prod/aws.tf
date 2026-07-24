resource "aws_vpc" "vpc" {
  cidr_block           = local.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.default_tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.default_tags
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(local.aws_vpc_cidr, 8, 1)
  availability_zone       = local.aws_az_a
  map_public_ip_on_launch = true
  tags                    = local.default_tags
}

resource "aws_route_table" "public_subnet_a_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = local.default_tags
}

resource "aws_route_table_association" "public_subnet_a_rt_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_subnet_a_rt.id
}

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
  # ami                         = "ami-0da1f66573556d917" # Debian 13
  ami                         = "ami-0303e2e4a29f041a3" # Ubuntu 26.04
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash

    set -euo errexit
    set -euo nounset
    set -euo pipefail

    apt update -y
    apt install -y wireguard

    # Add the node to the WireGuard network
    echo "[Interface]" >> /etc/wireguard/wg0.conf
    echo "PrivateKey = ${var.wg_shoot_work_01_private_key}" >> /etc/wireguard/wg0.conf
    echo "Address = 10.0.0.4/24" >> /etc/wireguard/wg0.conf
    echo "[Peer]" >> /etc/wireguard/wg0.conf
    echo "PublicKey = ${var.wg_proxmox_public_key}" >> /etc/wireguard/wg0.conf
    echo "Endpoint = proxmox.${local.org}.com:51820" >> /etc/wireguard/wg0.conf
    echo "AllowedIPs = 10.0.0.0/0" >> /etc/wireguard/wg0.conf
    echo "PersistentKeepalive = 25" >> /etc/wireguard/wg0.conf
    chmod 600 /etc/wireguard/wg0.conf

    systemctl enable wg-quick@wg0

    # Trigger kubeadm-init Ansible playbook
    # curl -fsSL -X POST \
    #     -H "Accept: application/vnd.github+json" \
    #     -H "Authorization: Bearer ${var.gh_access_token}" \
    #     -H "X-GitHub-Api-Version: 2022-11-28" \
    #     "https://api.github.com/repos/${local.org}/infra/dispatches" \
    #     -d "$(jq -n --arg vm "prod-shoot-work-01-1" '{
    #         event_type: "kubeadm-init",
    #         client_payload: { target_vm: $vm }
    #     }')"
  EOF

  root_block_device {
    iops        = 3000
    volume_size = 12
    volume_type = "gp3"
  }

  credit_specification {
    cpu_credits = "standard"
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
