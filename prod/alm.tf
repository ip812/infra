################################################################################
#                                     AWS                                      #
################################################################################

resource "aws_cloudwatch_metric_alarm" "asg_high_cpu_alarm" {
  alarm_name          = "asg-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.asg_scale_out_policy.arn]
  alarm_description   = "Alarm when CPU exceeds 75%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "asg_two_instances_alarm" {
  alarm_name          = "asg-two-instances-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.asg_scale_in_policy.arn]
  alarm_description   = "Triggers when the ASG has 2 instances"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  insufficient_data_actions = []
}

################################################################################
#                                Grafana Cloud                                 #
################################################################################
