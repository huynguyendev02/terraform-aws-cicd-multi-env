
variable "hostzone_id" {
  description = "The ID of the Route 53 Hosted Zone"
  type        = string
}

variable "name" {
  description = "The name of the Route 53 record"
  type        = string
}
variable "health_check_id" {
  description = "The name of the Route 53 record"
  type        = string
  default = null
}

variable "type" {
  description = "The type of the Route 53 record"
  type        = string
}

variable "set_identifier" {
  description = "The set identifier for the Route 53 record"
  type        = string
}

variable "failover_routing_policy_type" {
  description = "The failover routing policy type for the Route 53 record"
  type        = string
}

variable "alias_dns_name" {
  description = "The DNS name of the alias target"
  type        = string
  default = null
}

variable "alias_zone_id" {
  description = "The zone ID of the alias target"
  type        = string
}
