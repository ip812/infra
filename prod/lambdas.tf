# hello
resource "aws_iam_role" "hello_function_role" {
  name = "${var.org}-${var.env}-hello-function-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "hello_function_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.hello_function_role.name
}

resource "aws_lambda_function" "hello_function" {
  function_name = "hello"
  timeout       = 5
  image_uri     = "678468774710.dkr.ecr.eu-central-1.amazonaws.com/ip812/hello:42.1.0"
  package_type  = "Image"
  role          = aws_iam_role.hello_function_role.arn
  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_group_ids = [aws_security_group.asg_sg.id]
  }
  environment {
    variables = {
      APP_ENV = var.env
    }
  }
  tags = local.default_tags
}

# pg-query-exec 
resource "aws_iam_role" "pg_query_exec_function_role" {
  name = "${var.org}-${var.env}-pg-query-exec-function-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "pg_query_exec_function_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.pg_query_exec_function_role.name
}

resource "aws_lambda_function" "pg_query_exec_function" {
  function_name = "pg-query-exec"
  timeout       = 5
  image_uri     = "678468774710.dkr.ecr.eu-central-1.amazonaws.com/ip812/pg-query-exec:1.1.0"
  package_type  = "Image"
  role          = aws_iam_role.pg_query_exec_function_role.arn
  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_group_ids = [aws_security_group.asg_sg.id]
  }
  environment {
    variables = {
      APP_ENV     = var.env
      DB_HOST     = aws_db_instance.pg.endpoint
      DB_USERNAME = var.pg_username
      DB_PASSWORD = var.pg_password
      DB_SSL_MODE = "require"
    }
  }
  tags = local.default_tags
}

# ecr-push-notifier
resource "aws_iam_role" "ecr_push_notifier_function_role" {
  name = "${var.org}-${var.env}-ecr-push-notifier-function-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "ecr_push_notifier_function_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.ecr_push_notifier_function_role.name
}

resource "aws_lambda_function" "ecr_push_notifier_function" {
  function_name = "ecr-push-notifier"
  timeout       = 60
  image_uri     = "678468774710.dkr.ecr.eu-central-1.amazonaws.com/ip812/ecr-push-notifier:0.3.1"
  package_type  = "Image"
  role          = aws_iam_role.ecr_push_notifier_function_role.arn
  environment {
    variables = {
      APP_ENV           = var.env
      GIT_USERNAME      = var.gh_username
      GIT_ACCESS_TOKEN  = var.gh_access_token
    }
  }
  tags = local.default_tags
}
