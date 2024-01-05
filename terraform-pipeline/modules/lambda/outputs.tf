# Lambda function output
output "function" {
  value = aws_lambda_function.function
}

# Lambda permission output
output "permission" {
  value = aws_lambda_permission.permission
}
