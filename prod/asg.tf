resource "aws_security_group" "asg_sg" {
  vpc_id  = aws_vpc.vpc.id
  ingress = []
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "session manager"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = -1
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  tags = local.default_tags
}

resource "aws_iam_role" "asg_role" {
  name = "${var.org}-${var.env}-ec2-role"
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

resource "aws_iam_policy" "asg_policy" {
  name = "${var.org}-${var.env}-asg-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "asg_policy_attachment" {
  role       = aws_iam_role.asg_role.name
  policy_arn = aws_iam_policy.asg_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.org}-${var.env}-ec2-profile"
  role = aws_iam_role.asg_role.name
}

resource "random_string" "asg_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_launch_template" "asg_lt" {
  name_prefix            = "asg-lt-"
  image_id               = "ami-0a628e1e89aaedf80"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  monitoring {
    enabled = true
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Dependencies
    echo "Updating and installing dependencies starts"
    apt-get update -y
    apt-get install -y tmux vim curl unzip
    echo "Updating and installing dependencies ends"

    # AWS CLI
    echo "Installing AWS CLI starts"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    echo "Installing AWS CLI ends"

    # AWS credentials & config
    echo "Setting up AWS credentials starts"
    mkdir -p ~/.aws
    echo -e "[default]\nregion = ${var.aws_region}\noutput = json" > ~/.aws/config
    echo -e "[default]\naws_access_key_id = ${var.aws_access_key}\naws_secret_access_key = ${var.aws_secret_key}" > ~/.aws/credentials
    echo "Setting up AWS credentials ends"

    # Dotfiles
    echo "Setting up dotfiles starts"
    cd /home/ubuntu
    git clone https://github.com/iypetrov/.vm-dotfiles.git
    chmod -R ugo+r /home/ubuntu/.vm-dotfiles
    ln -s /home/ubuntu/.vm-dotfiles/.tmux.conf /root/.tmux.conf
    ln -s /home/ubuntu/.vm-dotfiles/.vimrc /root/.vimrc
    echo "Setting up dotfiles ends"

    # k3s
    curl -sfL https://get.k3s.io | sh -
    echo "K3s installed"
    systemctl start k3s
    echo "K3s started"

    # Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo "Helm installed"

    # Bootstrap
    git clone https://${var.gh_access_token}@github.com/ip812/apps.git

    kubectl create secret generic hcp-credentials \
      --namespace hcp-vault \
      --from-literal=clientID=${var.hcp_client_id} \
      --from-literal=clientSecret=${var.hcp_client_secret}
    kubectl create secret generic slk-bot-token \
      --namespace hcp-vault \
      --from-literal=clientID=${var.slk_bot_token}

    kubectl apply -f ./bootstrap/ --recursive

    helm repo add hashicorp https://helm.releases.hashicorp.com
	  helm install vault-secrets-operator hashicorp/vault-secrets-operator -n hcp-vault --create-namespace
	  helm repo add traefik https://helm.traefik.io/traefik
	  helm install traefik traefik/traefik -n traefik -f values/traefik.yml --create-namespace
	  helm repo add argo https://argoproj.github.io/argo-helm
	  helm install updater argo/argocd-image-updater -n argocd -f values/image-updater.yaml
  EOF
  )
  dynamic "tag_specifications" {
    for_each = toset(["instance"])
    content {
      resource_type = tag_specifications.key
      tags = merge(
        local.default_tags,
        {
          Name = "asg-instance-${random_string.asg_suffix.result}"
        }
      )
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = aws_launch_template.asg_lt.latest_version
  }
  name                      = "${var.org}-${var.env}-asg"
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  vpc_zone_identifier       = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  force_delete              = true
  wait_for_capacity_timeout = "0"
  health_check_type         = "EC2"
  health_check_grace_period = 60
  termination_policies      = ["OldestInstance"]
  enabled_metrics           = ["GroupInServiceInstances"]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage       = 100
      scale_in_protected_instances = "Refresh"
    }
  }

  lifecycle {
    replace_triggered_by = [
      aws_security_group.asg_sg,
      aws_security_group.asg_sg.ingress,
      aws_security_group.asg_sg.egress
    ]
  }
}

resource "aws_autoscaling_policy" "asg_scale_in_policy" {
  name                   = "${var.org}-${var.env}-asg-scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  enabled                = true
  cooldown               = 60
  scaling_adjustment     = -1
}

resource "aws_autoscaling_policy" "asg_scale_out_policy" {
  name                   = "${var.org}-${var.env}-asg-scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  enabled                = true
  cooldown               = 60
  scaling_adjustment     = 1
}
