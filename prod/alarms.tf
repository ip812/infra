resource "aws_cloudwatch_metric_alarm" "asg_high_cpu_alarm" {
  alarm_name          = "asg-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 90
  actions_enabled     = true
  alarm_description   = "Alarm when ASG CPU exceeds max threshold"
  alarm_actions = [
    aws_sns_topic.alarms_topic.arn,
    aws_autoscaling_policy.asg_scale_out_policy.arn
  ]
  ok_actions = [
    aws_sns_topic.alarms_topic.arn
  ]
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_high_cpu_alarm" {
  alarm_name          = "rds-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 90
  actions_enabled     = true
  alarm_description   = "Alarm when RDS CPU exceeds max threshold"
  alarm_actions = [
    aws_sns_topic.alarms_topic.arn
  ]
  ok_actions = [
    aws_sns_topic.alarms_topic.arn
  ]
  insufficient_data_actions = []
  dimensions = {
     DBInstanceIdentifier = aws_db_instance.pg.id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_low_storage_alarm" {
  alarm_name          = "rds-low-storage-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Minimum"
  threshold           = 2147483648 # 2 GB
  actions_enabled     = true
  alarm_description   = "Alarm when RDS free storage is less than 2 GB"
  alarm_actions = [
    aws_sns_topic.alarms_topic.arn
  ]
  ok_actions = [
    aws_sns_topic.alarms_topic.arn
  ]
  insufficient_data_actions = []
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.pg.id
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_two_instances_alarm" {
  alarm_name                = "asg-two-instances-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "GroupInServiceInstances"
  namespace                 = "AWS/AutoScaling"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 2
  actions_enabled           = true
  alarm_actions             = [aws_autoscaling_policy.asg_scale_in_policy.arn]
  alarm_description         = "Triggers when the ASG has 2 instances"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_sns_topic" "alarms_topic" {
  name = "alarms-notifications"
}

resource "aws_iam_role" "alarms_chatbot_role" {
  name = "alarms-chatbot-role"
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

resource "aws_iam_policy" "alarms_chatbot_policy" {
  name = "alarms-chatbot-policy"
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

resource "aws_iam_role_policy_attachment" "alarms_chatbot_policy_attachment" {
  role       = aws_iam_role.alarms_chatbot_role.name
  policy_arn = aws_iam_policy.alarms_chatbot_policy.arn
}

resource "awscc_chatbot_slack_channel_configuration" "alarms_slack_channel" {
  configuration_name = "alarms-slack-bot"
  iam_role_arn       = aws_iam_role.alarms_chatbot_role.arn
  slack_channel_id   = "C08KHNUASJ3"
  slack_workspace_id = "T08L95ER4JV"
  logging_level      = "INFO"
  sns_topic_arns = [
    aws_sns_topic.alarms_topic.arn
  ]
}
