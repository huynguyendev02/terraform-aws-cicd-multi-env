resource "aws_iam_role" "role" {
  name = var.name
  assume_role_policy = var.assume_role_policy
  tags = {
    Name = var.name
  }
}
resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = var.policy_arn
  role       = aws_iam_role.role.name
}