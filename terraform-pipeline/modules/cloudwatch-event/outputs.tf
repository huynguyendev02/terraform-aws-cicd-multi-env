# CloudWatch Event Rule Output
output "rule" {
  value = aws_cloudwatch_event_rule.rule
}

# CloudWatch Event Target Output
output "target" {
  value = aws_cloudwatch_event_target.target
}
