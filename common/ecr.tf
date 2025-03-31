################################################################################
#                                    Common                                    #
################################################################################

resource "aws_ecr_repository" "go_ssr_ecr_repository" {
  name                 = "${data.terraform_remote_state.prod.outputs.org}/go-ssr"
  image_tag_mutability = "IMMUTABLE"
}
################################################################################
#                                   Services                                   #
################################################################################

resource "aws_ecr_repository" "go_template_ecr_repository" {
  name                 = "${data.terraform_remote_state.prod.outputs.org}/go-template"
  image_tag_mutability = "IMMUTABLE"
}

################################################################################
#                                   Lambdas                                    #
################################################################################

resource "aws_ecr_repository" "hello_ecr_repository" {
  name                 = "${data.terraform_remote_state.prod.outputs.org}/hello"
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository" "pg_query_exec_ecr_repository" {
  name                 = "${data.terraform_remote_state.prod.outputs.org}/pg-query-exec"
  image_tag_mutability = "IMMUTABLE"
}
