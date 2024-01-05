output "rds_master" {
    value = aws_db_instance.rds_master
}

output "rds_random_password" {
    value = random_password.default_password.result
}