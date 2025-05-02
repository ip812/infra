################################################################################
#                                   Variables                                  #
################################################################################

variable "gf_region_slug" {
  type = string
}

variable "gf_aws_account_id" {
  type = string
}

################################################################################
#                                    Stacks                                    #
################################################################################

resource "grafana_cloud_stack" "stack" {
  provider    = grafana.cloud
  name        = "${var.org}.grafana.net"
  slug        = var.org
  region_slug = var.gf_region_slug
}

output "prometheus_remote_endpoint" {
  value = grafana_cloud_stack.stack.prometheus_remote_endpoint
}

output "logs_url" {
  value = grafana_cloud_stack.stack.logs_url
}

output "trace_url" {
  value = grafana_cloud_stack.stack.traces_url
}

output "fleet_management_url" {
  value = grafana_cloud_stack.stack.fleet_management_url
}

resource "grafana_cloud_access_policy" "access_policy" {
  provider     = grafana.cloud
  region       = var.gf_region_slug
  name         = "${var.org}-access-policy"
  display_name = "${var.org}-access-policy"
  scopes = [
    "integration-management:read",
    "integration-management:write",
    "stacks:read",
  ]
  realm {
    type       = "stack"
    identifier = grafana_cloud_stack.stack.id
  }
}

resource "grafana_cloud_access_policy_token" "access_policy_token" {
  provider         = grafana.cloud
  region           = var.gf_region_slug
  access_policy_id = grafana_cloud_access_policy.access_policy.policy_id
  name             = "${var.org}-access-policy-token"
  display_name     = "${var.org}-access-policy-token"
  depends_on = [
    grafana_cloud_access_policy.access_policy,
  ]
}

data "aws_iam_policy_document" "trust_grafana" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.gf_aws_account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "grafana_labs_cloudwatch_integration_role" {
  name               = "${var.org}-${var.env}-grafana-labs-cloudwatch-integration-role"
  assume_role_policy = data.aws_iam_policy_document.trust_grafana.json
}

resource "aws_iam_role_policy" "grafana_labs_cloudwatch_integration_policy" {
  name = "${var.org}-${var.env}-grafana-labs-cloudwatch-integration-policy"
  role = aws_iam_role.grafana_labs_cloudwatch_integration_role.id

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

resource "time_sleep" "wait_300_seconds" {
  depends_on = [
    aws_iam_role.grafana_labs_cloudwatch_integration_role,
    aws_iam_role_policy.grafana_labs_cloudwatch_integration_policy,
  ]
  create_duration = "300s"
}

################################################################################
#                                    Scraper                                   #
################################################################################

provider "grafana" {
  alias                       = "stack"
  cloud_provider_access_token = grafana_cloud_access_policy_token.access_policy_token.token
  cloud_provider_url          = "https://cloud-provider-api-${var.gf_region_slug}.grafana.net"
}

resource "grafana_cloud_provider_aws_account" "aws_acc" {
  depends_on = [time_sleep.wait_300_seconds]
  provider   = grafana.stack
  stack_id   = grafana_cloud_stack.stack.id
  role_arn   = aws_iam_role.grafana_labs_cloudwatch_integration_role.arn
  regions    = [var.aws_region]
}

resource "grafana_cloud_provider_aws_cloudwatch_scrape_job" "aws_cw_scrape_job" {
  provider                = grafana.stack
  stack_id                = grafana_cloud_stack.stack.id
  name                    = "${var.org}-${var.env}-aws-cloudwatch-scrape-job"
  aws_account_resource_id = grafana_cloud_provider_aws_account.aws_acc.resource_id
  service {
    name = "AWS/RDS"
    metric {
      name       = "CPUUtilization"
      statistics = ["Average"]
    }
    metric {
      name       = "FreeStorageSpace"
      statistics = ["Average"]
    }
    metric {
      name       = "ReadIOPS"
      statistics = ["Average"]
    }
    metric {
      name       = "WriteIOPS"
      statistics = ["Average"]
    }
    metric {
      name       = "DatabaseConnections"
      statistics = ["Average"]
    }
    metric {
      name       = "DiskQueueDepth"
      statistics = ["Average"]
    }
    metric {
      name       = "ReadLatency"
      statistics = ["Average"]
    }
    metric {
      name       = "WriteLatency"
      statistics = ["Average"]
    }
  }
}
