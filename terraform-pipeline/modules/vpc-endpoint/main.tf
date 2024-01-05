resource "aws_vpc_endpoint" "vpc_endpoint" {
  service_name      = var.service_name
  vpc_endpoint_type = var.vpc_endpoint_type
  subnet_ids        = var.subnet_ids
  route_table_ids = var.route_table_ids

  vpc_id            = var.vpc_id


  security_group_ids = var.security_group_ids

  private_dns_enabled = var.private_dns_enabled
  tags = {
    Name = var.name
  }
}