################################################################################
#                                     AWS                                      #
################################################################################

resource "aws_cloudwatch_metric_alarm" "asg_high_cpu_alarm" {
  alarm_name                = "asg-high-cpu-utilization-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 75
  alarm_description         = "Alarm when CPU exceeds 75%"
  actions_enabled           = true
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_actions = [
    aws_autoscaling_policy.asg_scale_in_policy.arn
  ]
}

################################################################################
#                                Grafana Cloud                                 #
################################################################################
