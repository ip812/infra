################################################################################
#                                     AWS                                      #
################################################################################

resource "aws_cloudwatch_metric_alarm" "vm_cpu_alarm" {
  alarm_name                = "vm-cpu-utilization-alarm"
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
    AutoScalingGroupName = aws_autoscaling_group.vm_asg.name
  }
  alarm_actions = [
    aws_autoscaling_group.vm_asg.arn
  ]
}
