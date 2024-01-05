
variable "schedule_expression" {
  description = "The schedule expression for the CloudWatch Event Rule"
  type        = string
}

variable "name" {
  description = "The name of the CloudWatch Event Rule"
  type        = string
}

variable "description" {
  description = "The description of the CloudWatch Event Rule"
  type        = string
}

variable "target_arn" {
  description = "The ARN of the CloudWatch Event Target"
  type        = string
}
variable "target_id" {
  type        = string
  default = null
}