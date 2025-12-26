resource "aws_security_group" "asg_sg" {
  vpc_id  = aws_vpc.vpc.id
  ingress = []
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow all outbound traffic"
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
  name = "${local.org}-${local.env}-ec2-role"
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
  name = "${local.org}-${local.env}-asg-policy"
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
  name = "${local.org}-${local.env}-ec2-profile"
  role = aws_iam_role.asg_role.name
}

resource "random_string" "asg_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_launch_template" "asg_lt" {
  name_prefix = "asg-lt-"
  # image_id               = "ami-0a628e1e89aaedf80"
  image_id               = "ami-058d51b1d804d89e3"
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  monitoring {
    enabled = true
  }
  user_data = base64encode(<<-EOF
#!/bin/bash

# apt-get update -y
# apt-get install -y curl wget unzip make git vim tmux
# curl -fsSL https://tailscale.com/install.sh | sh
# tailscale up --authkey ${var.ts_auth_key} --hostname "${local.org}-${local.env}" --ssh
# 
# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san ${local.org}-${local.env} --https-listen-port 16443" sh -
# echo "alias kubectl='k3s kubectl'" >> /root/.bashrc
# echo "alias k='k3s kubectl'" >> /root/.bashrc
# foo

k3s kubectl cordon ip-10-0-2-54
while read LINE; do
  NAMESPACE="$(echo $LINE | awk '{ print $1 }')"
  POD_NAME="$(echo $LINE | awk '{ print $2 }')"
  k3s kubectl delete pod $POD_NAME -n $NAMESPACE --grace-period=0 --force
done < <(k3s kubectl get pods -A | grep Terminating | awk '{ print $1 " " $2 }')
k3s kubectl delete node ip-10-0-2-54

KUBECONFIG=/etc/rancher/k3s/k3s.yaml k3s kubectl create namespace doppler-operator-system
KUBECONFIG=/etc/rancher/k3s/k3s.yaml k3s kubectl create secret generic doppler-token-secret -n doppler-operator-system --from-literal=serviceToken=${var.dp_token}

curl -s https://fluxcd.io/install.sh | sudo bash
KUBECONFIG=/etc/rancher/k3s/k3s.yaml GITHUB_TOKEN=${var.gh_access_token} flux bootstrap github \
	    --token-auth=true \
	    --owner=ip812 \
	    --repository=apps \
	    --branch=main \
	    --path=envs/prod \
	    --read-write-key=true \
	    --personal=false
EOF
  )

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 15
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = false
    }
  }

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
  name                      = "${local.org}-${local.env}-asg"
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  vpc_zone_identifier       = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  force_delete              = true
  wait_for_capacity_timeout = "0"
  health_check_type         = "EC2"
  health_check_grace_period = 300
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
  name                   = "${local.org}-${local.env}-asg-scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  enabled                = true
  cooldown               = 300
  scaling_adjustment     = -1
}

resource "aws_autoscaling_policy" "asg_scale_out_policy" {
  name                   = "${local.org}-${local.env}-asg-scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  enabled                = true
  cooldown               = 300
  scaling_adjustment     = 1
}
