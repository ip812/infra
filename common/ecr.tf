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

resource "aws_ecr_repository" "db_query_exec_ecr_repository" {
  name                 = "${data.terraform_remote_state.prod.outputs.org}/db-query-exec"
  image_tag_mutability = "IMMUTABLE"
}
