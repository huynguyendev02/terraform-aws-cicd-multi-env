variable "db_subnets_name" {
}
variable "db_subnets" {
}
variable "db_instance_name" {
}
variable "db_instance_storage" {
}
variable "db_instance_engine" {
}
variable "db_instance_engine_version" {
}
variable "db_instance_class" {
}
variable "db_name" {
}
variable "db_username" {
}
variable "backup_retention_period" {
    default = 0
}
variable "multi_az" {
    default = false
}
variable "db_instance_sg" {
}
variable "storage_encrypted" {
    default = false
}