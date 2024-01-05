resource "aws_db_subnet_group" "database_subnet" {
  name = var.db_subnets_name
  subnet_ids = var.db_subnets
  tags = {
    Name = var.db_subnets_name
  }
}

resource "aws_db_instance" "rds_master" {
  identifier              = var.db_instance_name
  allocated_storage       = var.db_instance_storage
  engine                  = var.db_instance_engine
  engine_version          = var.db_instance_engine_version
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.default_password.result
  backup_retention_period = var.backup_retention_period
  multi_az                = var.multi_az
  db_subnet_group_name    = aws_db_subnet_group.database_subnet.id
  skip_final_snapshot     = true
  vpc_security_group_ids  = var.db_instance_sg
  storage_encrypted       = var.storage_encrypted
  tags = {
    Name = var.db_instance_name
  }
}

resource "random_password" "default_password" {
 length  = 20
 special = false
}