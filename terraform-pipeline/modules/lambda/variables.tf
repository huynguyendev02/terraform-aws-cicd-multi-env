variable "filename" {
  description = "The filename of the Lambda function"
}

variable "function_name" {
  description = "The name of the Lambda function"
}

variable "role" {
  description = "The ARN of the IAM role for the Lambda function"
}

variable "handler" {
  description = "The handler function for the Lambda function"
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
}

variable "lambda_permission_statement_id" {
  description = "The statement ID for the Lambda permission"
}

variable "lambda_permission_action" {
  description = "The action for the Lambda permission"
}

variable "lambda_permission_principal" {
  description = "The principal for the Lambda permission"
}

variable "lambda_permission_source_arn" {
  description = "The source ARN for the Lambda permission"
}
variable "environment_variables" {
}

