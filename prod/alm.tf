################################################################################
#                                     AWS                                      #
################################################################################

resource "aws_autoscaling_policy" "vm_scale_out_policy" {
  name                   = "scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 30
  autoscaling_group_name = aws_autoscaling_group.vm_asg.name
}

resource "aws_cloudwatch_metric_alarm" "vm_cpu_alarm" {
  alarm_name          = "vm-cpu-utilization-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Alarm when CPU exceeds 75%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.vm_asg.name
  }
  alarm_actions = [
    aws_autoscaling_policy.vm_scale_out_policy.arn
  ]
}
