resource "aws_cloudwatch_log_group" "log_group" {
  name = var.name

  tags = {
    Name = var.name
  }
}