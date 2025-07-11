resource "grafana_cloud_stack" "stack" {
  name        = "${var.org}.grafana.net"
  slug        = var.org
  region_slug = var.gf_region_slug
}

output "gf_cloud_stack" {
  value = grafana_cloud_stack.stack
}

resource "grafana_cloud_access_policy" "access_policy" {
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
  region           = var.gf_region_slug
  access_policy_id = grafana_cloud_access_policy.access_policy.policy_id
  name             = "${var.org}-access-policy-token"
  display_name     = "${var.org}-access-policy-token"
  depends_on = [
    grafana_cloud_access_policy.access_policy,
  ]
}

output "gf_cloud_provider_access_token" {
  value     = grafana_cloud_access_policy_token.access_policy_token.token
  sensitive = true
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

output "gf_labs_cloudwatch_integration_role_arn" {
  value = aws_iam_role.grafana_labs_cloudwatch_integration_role.arn
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
