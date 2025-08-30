resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "dream-instance-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    InstanceId = aws_instance.dream_instance.id
  }

  alarm_description = "This alarm triggers if CPU > 70% for 2 consecutive minutes"
  actions_enabled   = false
}
