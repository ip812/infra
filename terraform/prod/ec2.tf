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
  # ami                         = "ami-0a628e1e89aaedf80"
  ami                         = "ami-0b5ef45933f8fa37d"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    
    set -x
    
    # apt-get update -y
    # apt-get install -y curl wget unzip make git vim tmux
    # curl -fsSL https://tailscale.com/install.sh | sh
    # tailscale up --authkey ${var.ts_auth_key} --hostname "${local.org}-${local.env}" --ssh
    # 
    # curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san ${local.org}-${local.env} --https-listen-port 16443" sh -
    # echo "alias kubectl='k3s kubectl'" >> /root/.bashrc
    # echo "alias k='k3s kubectl'" >> /root/.bashrc
    # 
    # curl -s https://fluxcd.io/install.sh | sudo bash
    
    k3s kubectl cordon ip-10-0-1-214
    while read LINE; do
      NAMESPACE="$(echo $LINE | awk '{ print $1 }')"
      POD_NAME="$(echo $LINE | awk '{ print $2 }')"
      k3s kubectl delete pod $POD_NAME -n $NAMESPACE --grace-period=0 --force
    done < <(k3s kubectl get pods -A | grep Terminating | awk '{ print $1 " " $2 }')
    k3s kubectl delete node ip-10-0-1-214
    
    KUBECONFIG=/etc/rancher/k3s/k3s.yaml k3s kubectl create namespace doppler-operator-system
    KUBECONFIG=/etc/rancher/k3s/k3s.yaml k3s kubectl create secret generic doppler-token-secret -n doppler-operator-system --from-literal=serviceToken=${var.dp_token}
    
    KUBECONFIG=/etc/rancher/k3s/k3s.yaml GITHUB_TOKEN=${var.gh_access_token} flux bootstrap github \
    	    --token-auth=true \
    	    --owner=${local.org} \
    	    --repository=apps \
    	    --branch=main \
    	    --path=envs/${local.env} \
    	    --read-write-key=true \
    	    --personal=false
  EOF

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
