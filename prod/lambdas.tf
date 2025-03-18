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
  function_name = "hello-function"
  timeout       = 5
  image_uri     = "678468774710.dkr.ecr.eu-central-1.amazonaws.com/ip812/hello:0.1.0"
  package_type  = "Image"
  role          = aws_iam_role.hello_function_role.arn
  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_group_ids = [aws_security_group.vm_sg.id]
  }
  tags = local.default_tags
}

# db-query-exec 
resource "aws_iam_role" "db_query_exec_function_role" {
  name = "${var.org}-${var.env}-db-query-exec-function-role"
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

resource "aws_iam_role_policy_attachment" "db_query_exec_function_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.db_query_exec_function_role.name
}

resource "aws_lambda_function" "db_query_exec_function" {
  function_name = "db-query-exec-function"
  timeout       = 5
  image_uri     = "678468774710.dkr.ecr.eu-central-1.amazonaws.com/ip812/db-query-exec:0.3.1"
  package_type  = "Image"
  role          = aws_iam_role.db_query_exec_function_role.arn
  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_group_ids = [aws_security_group.vm_sg.id]
  }
  environment {
    variables = {
      DB_HOST     = aws_db_instance.db.endpoint
      DB_USERNAME = var.db_username
      DB_PASSWORD = var.db_password
    }
  }
  tags = local.default_tags
}
