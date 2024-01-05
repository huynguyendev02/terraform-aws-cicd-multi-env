# Lambda function
resource "aws_lambda_function" "function" {
  filename      = var.filename
  function_name = var.function_name
  role          = var.role
  handler       = var.handler
  runtime       = var.runtime

  environment {
    variables = var.environment_variables
  }
}

resource "aws_lambda_permission" "permission" {
  statement_id  = var.lambda_permission_statement_id
  action        = var.lambda_permission_action
  function_name = aws_lambda_function.function.function_name
  principal     = var.lambda_permission_principal
  source_arn    = var.lambda_permission_source_arn
}