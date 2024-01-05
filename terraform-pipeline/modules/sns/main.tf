resource "aws_sns_topic" "sns_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "sns_topic_sub" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = var.sns_topic_protocol
  endpoint  = var.sns_topic_endpoint
}