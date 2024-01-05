resource "aws_secretsmanager_secret" "secret" {
 name = var.name
 recovery_window_in_days = var.recovery_window_in_days
 tags = {
    Name = var.name
 }
}

resource "aws_secretsmanager_secret_version" "secret_string" {
 secret_id = aws_secretsmanager_secret.secret.id
 secret_string = var.secret_string
}