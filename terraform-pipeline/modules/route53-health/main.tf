resource "aws_route53_health_check" "health" {
  fqdn              = var.fqdn
  port              = var.port
  type              = var.type
  resource_path     = var.resource_path
  failure_threshold = var.failure_threshold
  request_interval  = var.request_interval
}