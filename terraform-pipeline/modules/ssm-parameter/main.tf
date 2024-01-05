resource "aws_ssm_parameter" "parameter" {
  name  = var.parameter["name"]
  type  = var.parameter["type"]
  value = var.parameter["value"]
}