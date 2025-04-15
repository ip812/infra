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
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  monitoring {
    enabled = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    echo "Updating and installing dependencies"
    apt-get update -y
    apt-get install -y curl wget unzip make git vim tmux

    echo "Installing AWS CLI"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install

    echo "Setting up AWS credentials"
    mkdir -p /root/.aws
    chmod 700 /root/.aws
    echo -e "[default]\nregion = ${var.aws_region}\noutput = json" > /root/.aws/config
    echo -e "[default]\naws_access_key_id = ${var.aws_access_key}\naws_secret_access_key = ${var.aws_secret_key}" > /root/.aws/credentials

    echo "Installing MicroK8s"
    apt install snapd
    snap install microk8s --classic
    microk8s status --wait-ready
    microk8s.kubectl config view --raw > $HOME/.kube/config

    echo "Setting up kubectl"
    ln -s /snap/bin/microk8s.kubectl /usr/local/bin/kubectl
    echo "alias kubectl='microk8s kubectl'" >> /root/.bashrc
    echo "alias k='microk8s kubectl'" >> /root/.bashrc

    echo "Setting up k9s"
    wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb
    apt install ./k9s_linux_amd64.deb

    echo "Installing Helm"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    echo "Setting up k8s cluster"
    git clone https://${var.gh_access_token}@github.com/ip812/apps.git
    microk8s kubectl create namespace argocd
    microk8s kubectl create namespace ip812
    microk8s kubectl create secret generic argocd-notifications-secret \
      --namespace argocd \
      --from-literal=slack-token="${var.slk_bot_token}"
    microk8s kubectl create secret generic hcp-credentials \
      --namespace ip812 \
      --from-literal=clientID="${var.hcp_client_id}" \
      --from-literal=clientSecret="${var.hcp_client_secret}"
    microk8s kubectl create secret docker-registry ecr-secret \
      --namespace ip812 \
      --docker-server=678468774710.dkr.ecr.${var.aws_region}.amazonaws.com \
      --docker-username=AWS \
      --docker-password=$(aws ecr get-login-password --region ${var.aws_region}) \
      --docker-email=ilia.yavorov.petrov@gmail.com
    microk8s helm3 repo add hashicorp https://helm.releases.hashicorp.com
    microk8s helm3 install vault-secrets-operator hashicorp/vault-secrets-operator -n ip812
    microk8s helm3 repo add traefik https://helm.traefik.io/traefik
    microk8s helm3 install traefik traefik/traefik -f apps/values/traefik.yaml -n ip812
    microk8s helm3 repo add argo https://argoproj.github.io/argo-helm
    microk8s helm3 install argocd argo/argo-cd -f apps/values/argocd.yaml -n argocd
    microk8s kubectl apply -k ./apps/manifests/prod
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
