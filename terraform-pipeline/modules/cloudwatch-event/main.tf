# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "rule" {
  schedule_expression = var.schedule_expression
  name                = var.name
  description         = var.description
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rule.name
  arn       = var.target_arn
}
