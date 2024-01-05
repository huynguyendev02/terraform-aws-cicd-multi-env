resource "aws_iam_instance_profile" "iam-instance-profile" {
  name = var.name
  role = var.iam_role_name
  tags = {
    Name = var.name
  }
}
