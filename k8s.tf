resource "aws_security_group" "asg_sg" {
  vpc_id  = aws_vpc.vpc.id
  ingress = []
  egress  = []
  tags    = local.default_tags
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
  name_prefix   = "asg-lt-"
  image_id      = "ami-0a628e1e89aaedf80"
  instance_type = "t3.medium"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.asg_sg.id]
  }
  user_data = base64encode(<<-EOF
#!/bin/bash

apt-get update -y
apt-get install -y curl wget unzip make git vim tmux postgresql-client

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

mkdir -p /root/.aws
chmod 700 /root/.aws
echo -e "[default]\nregion = ${var.aws_region}\noutput = json" > /root/.aws/config
echo -e "[default]\naws_access_key_id = ${var.aws_access_key_id}\naws_secret_access_key = ${var.aws_secret_access_key}" > /root/.aws/credentials

curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey ${var.ts_auth_key} --hostname "${var.org}-${var.env}-${random_string.asg_suffix.id}" --ssh

curl -sSf https://get.k0s.sh | sh
k0s install controller --single
k0s start
systemctl enable k0scontroller
export KUBECONFIG=/var/lib/k0s/pki/admin.conf
echo "export KUBECONFIG=/var/lib/k0s/pki/admin.conf" >> /root/.bashrc
echo "alias kubectl='k0s kubectl'" >> /root/.bashrc
echo "alias k='k0s kubectl'" >> /root/.bashrc
echo "Waiting for Kubernetes API to become available..." && until k0s kubectl get nodes >/dev/null 2>&1; do echo "Still waiting for the API..." && sleep 5; done && echo "Kubernetes API is ready."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

git clone https://${var.gh_access_token}@github.com/ip812/infra.git
k0s kubectl create namespace ip812
k0s kubectl create secret generic ip812-secrets \
  --namespace ip812 \
  --from-literal=aws_access_key_id="${var.aws_access_key_id}" \
  --from-literal=aws_secret_access_key="${var.aws_secret_access_key}" \
  --from-literal=aws_region="${var.aws_region}" \
  --from-literal=cf_tunnel_token="${cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.tunnel_token}" \
  --from-literal=pg_endpoint="postgres-svc.ip812.svc.cluster.local:5432" \
  --from-literal=pg_username="${var.pg_username}" \
  --from-literal=pg_password="${var.pg_password}" \
  --from-literal=go_template_pg_name="${var.go_template_db_name}"
k0s kubectl create secret docker-registry ecr-secret \
  --namespace ip812 \
  --docker-server=678468774710.dkr.ecr.${var.aws_region}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ${var.aws_region}) \
  --docker-email=ilia.yavorov.petrov@gmail.com

helm install --namespace ip812 --wait postgres ./infra/charts/postgres
helm install --namespace ip812 --wait go-template ./infra/charts/app
helm install --namespace ip812 --wait cloudflare-tunnel ./infra/charts/cloudflare-tunnel
sleep 10

echo "⏳ Waiting for Postgres pod to be Ready..."
for i in {1..30}; do
  if k0s kubectl get pod -n ip812 -l app=postgres -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q Running; then
    echo "✅ Postgres pod is running."
    break
  fi
  echo "🔁 Still waiting for pod... ($i)"
  sleep 2
done

# Final check
if ! k0s kubectl get pod -n ip812 -l app=postgres -o jsonpath='{.items[0].status.phase}' | grep -q Running; then
  echo "❌ Postgres pod is not ready after waiting. Exiting."
  exit 1
fi

echo "🚪 Starting port-forward to postgres-svc..."
k0s kubectl port-forward -n ip812 svc/postgres-svc 5432:5432 >/tmp/portforward.log 2>&1 &
pf_pid=$!
trap 'kill $pf_pid || true' EXIT

for i in {1..10}; do
  if nc -z 127.0.0.1 5432; then
    echo "✅ Port-forward established."
    break
  fi
  echo "🔁 Waiting for port 5432 to be ready... ($i)"
  sleep 5
done

if ! nc -z 127.0.0.1 5432; then
  echo "❌ Port-forward failed. Port is not open after waiting."
  cat /tmp/portforward.log
  exit 1
fi

# Run the psql command
echo "📦 Running database creation SQL..."
PGPASSWORD="${var.pg_password}" psql -U "${var.pg_username}" -h 127.0.0.1 -p 5432 -d postgres -c "CREATE DATABASE ${var.go_template_db_name};"
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
