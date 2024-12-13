resource "github_actions_secret" "apps_aws_account_id" {
 repository      = "apps"
 secret_name     = "AWS_REGION"
 plaintext_value = var.aws_region
}

resource "github_actions_secret" "apps_aws_access_key" {
 repository      = "apps"
 secret_name     = "AWS_ACCESS_KEY_ID"
 plaintext_value = var.aws_access_key
}

resource "github_actions_secret" "apps_aws_secret_key" {
 repository      = "apps"
 secret_name     = "AWS_SECRET_ACCESS_KEY"
 plaintext_value = var.aws_secret_key
}

resource "github_actions_secret" "apps_deploy_ssh_private_key" {
 repository      = "apps"
 secret_name     = "SSH_PRIVATE_KEY"
 plaintext_value = var.deploy_ssh_private_key
}

resource "github_actions_secret" "apps_hostname" {
 repository      = "apps"
 secret_name     = "HOSTNAME"
 plaintext_value = aws_eip.eip.public_ip
}

resource "github_actions_secret" "apps_github_access_token" {
 repository      = "apps"
 secret_name     = "REPO_TOKEN"
 plaintext_value = var.github_access_token
}

resource "github_actions_secret" "blog_aws_account_id" {
 repository      = "blog"
 secret_name     = "AWS_REGION"
 plaintext_value = var.aws_region
}

resource "github_actions_secret" "blog_aws_access_key" {
 repository      = "blog"
 secret_name     = "AWS_ACCESS_KEY_ID"
 plaintext_value = var.aws_access_key
}

resource "github_actions_secret" "blog_aws_secret_key" {
 repository      = "blog"
 secret_name     = "AWS_SECRET_ACCESS_KEY"
 plaintext_value = var.aws_secret_key
}

resource "github_actions_secret" "blog_github_access_token" {
 repository      = "blog"
 secret_name     = "REPO_TOKEN"
 plaintext_value = var.github_access_token
}

resource "github_actions_secret" "infr_terrafrom_token" {
 repository      = "infr"
 secret_name     = "TF_TOKEN"
 plaintext_value = var.terraform_token
}
