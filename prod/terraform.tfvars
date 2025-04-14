org = "ip812"
env = "prod"

# The region should match Grafana Cloud's region
# https://grafana.com/docs/grafana-cloud/account-management/regional-availability/
aws_region                = "eu-central-1"
aws_az_a                  = "eu-central-1a"
aws_az_b                  = "eu-central-1b"
aws_vpc_cidr              = "10.0.0.0/16"
aws_public_subnet_a_cidr  = "10.0.1.0/24"
aws_public_subnet_b_cidr  = "10.0.2.0/24"
aws_private_subnet_a_cidr = "10.0.3.0/24"
aws_private_subnet_b_cidr = "10.0.4.0/24"

cf_tunnel_name = "ip812_tunnel"

pgadmin_domain = "pgadmin"

go_template_domain      = "template"
go_template_db_name     = "go-template"
