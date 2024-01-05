
variable "fqdn" {
  description = "The fully qualified domain name (FQDN) or endpoint to check."
  type        = string
}

variable "port" {
  description = "The port on which to open the connection."
  type        = number
}

variable "type" {
  description = "The type of health check to perform."
  type        = string
}

variable "resource_path" {
  description = "The path to the resource to check."
  type        = string
}

variable "failure_threshold" {
  description = "The number of consecutive health checks that must fail before the resource is considered unhealthy."
  type        = number
}

variable "request_interval" {
  description = "The number of seconds between the time that Amazon Route 53 gets a response from your endpoint and the time that it sends the next health check request."
  type        = number
}
