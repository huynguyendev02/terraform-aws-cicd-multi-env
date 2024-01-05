resource "aws_route53_record" "record" {
  zone_id = var.hostzone_id
  name    = var.name
  type    = var.type

  dynamic "alias" {
    for_each = var.alias_dns_name != null ? [1] : []
    content {
      name                   = var.alias_dns_name
      zone_id                = var.alias_zone_id
      evaluate_target_health = true
    }
  }

  set_identifier = var.set_identifier
  health_check_id = var.health_check_id

  failover_routing_policy {
    type = var.failover_routing_policy_type
  }
}