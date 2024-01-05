resource "aws_iam_policy" "policy" {
  name        = var.name
  description = var.description

  policy = var.policy
  tags = {
    Name = var.name
  }
}