resource "grafana_cloud_stack" "stack" {
  name        = "${local.org}.grafana.net"
  slug        = local.org
  region_slug = local.gf_region_slug
}

resource "grafana_cloud_access_policy" "access_policy" {
  region       = local.gf_region_slug
  name         = "${local.org}-access-policy"
  display_name = "${local.org}-access-policy"
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
  region           = local.gf_region_slug
  access_policy_id = grafana_cloud_access_policy.access_policy.policy_id
  name             = "${local.org}-access-policy-token"
  display_name     = "${local.org}-access-policy-token"
  depends_on = [
    grafana_cloud_access_policy.access_policy,
  ]
}

data "aws_iam_policy_document" "trust_grafana" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.gf_aws_account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "grafana_labs_cloudwatch_integration_role" {
  name               = "${local.org}-${local.env}-grafana-labs-cloudwatch-integration-role"
  assume_role_policy = data.aws_iam_policy_document.trust_grafana.json
}

resource "aws_iam_role_policy" "grafana_labs_cloudwatch_integration_policy" {
  name = "${local.org}-${local.env}-grafana-labs-cloudwatch-integration-policy"
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
