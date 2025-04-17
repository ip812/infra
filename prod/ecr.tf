resource "aws_cloudwatch_event_rule" "ecr_push_rule" {
  name        = "ecr-image-push"
  description = "Trigger Lambda on ECR image push (any repository)"
  event_pattern = jsonencode({
    source       = ["aws.ecr"],
    "detail-type" = ["ECR Image Action"],
    detail       = {
      "action-type" = ["PUSH"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.ecr_push_rule.name
  arn       = aws_lambda_function.hello_function.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_push_rule.arn
}
