################################################################################
#                                  Functions                                   #
################################################################################

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
  image_uri     = "678468774710.dkr.ecr.eu-central-1.amazonaws.com/ip812/hello:0.1.0"
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
  image_uri     = "678468774710.dkr.ecr.eu-central-1.amazonaws.com/ip812/pg-query-exec:0.1.1"
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

################################################################################
#                                 Notifications                                #
################################################################################

resource "aws_sns_topic" "lambda_deploys_topic" {
  name = "lambda-deploys-notifications"
}

resource "aws_iam_role" "lambda_deploys_chatbot_role" {
  name = "lambda-deploys-chatbot-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "chatbot.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_deploys_chatbot_policy" {
  name = "lambda-deploys-chatbot-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "sns:Publish"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_deploys_chatbot_policy_attachment" {
  role       = aws_iam_role.lambda_deploys_chatbot_role.name
  policy_arn = aws_iam_policy.lambda_deploys_chatbot_policy.arn
}

resource "awscc_chatbot_slack_channel_configuration" "lambda_deploys_slack_channel" {
  configuration_name = "lambda-deploys-slack-bot"
  iam_role_arn       = aws_iam_role.lambda_deploys_chatbot_role.arn
  slack_channel_id   = "C08NQMY5MA4"
  slack_workspace_id = "T08L95ER4JV"
  logging_level      = "INFO"
  sns_topic_arns = [
    aws_sns_topic.lambda_deploys_topic.arn
  ]
}

resource "aws_cloudwatch_event_rule" "lambda_update" {
  name        = "lambda-update-event"
  description = "Catch all Lambda function updates and notify SNS"
  event_pattern = jsonencode({
    "source": ["aws.lambda"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": ["lambda.amazonaws.com"],
      "eventName": ["UpdateFunctionCode"]
    }
  })
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.lambda_update.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.lambda_deploys_topic.arn
}

resource "aws_sns_topic_policy" "allow_eventbridge" {
  arn    = aws_sns_topic.lambda_deploys_topic.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "events.amazonaws.com" },
      Action    = "sns:Publish",
      Resource  = aws_sns_topic.lambda_deploys_topic.arn
    }]
  })
}
