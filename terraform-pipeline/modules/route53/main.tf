data "aws_route53_delegation_set" "main" {
  id = var.delegation_set
}
resource "aws_route53_zone" "primary_zone" {
  name = var.domain
  delegation_set_id = data.aws_route53_delegation_set.main.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "zone-${var.project_name}"
  }
}