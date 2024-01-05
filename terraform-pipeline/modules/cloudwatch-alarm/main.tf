resource "aws_cloudwatch_metric_alarm" "backend_health" {
  alarm_name          = var.cloudwatch_alarm_name
  alarm_description   = var.cloudwatch_alarm_description
  metric_name         = var.cloudwatch_alarm_metric_name

  comparison_operator = var.cloudwatch_alarm_comparison_operator
  evaluation_periods  = var.cloudwatch_alarm_evaluation_periods
  namespace           = var.cloudwatch_alarm_namespace
  period              = var.cloudwatch_alarm_period
  statistic           = var.cloudwatch_alarm_statistic
  threshold           = var.cloudwatch_alarm_threshold
  alarm_actions       = var.cloudwatch_alarm_alarm_actions

  dimensions =  var.cloudwatch_alarm_dimensions
  tags = {
    Name = var.cloudwatch_alarm_name
  }
}