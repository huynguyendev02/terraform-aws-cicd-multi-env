variable "project_name" {
  type = string
}
variable "project_tag" {
  type = string
}
variable "owner_tag" {
  type = string
}
variable "region" {
  default = "ap-southeast-1"
  type = string
}
variable "account_id" {
  default = "816722035531"
  type = string
}
####NETWORK#####
variable "network_cidr" {
  type = string
}
variable "networks" {
  type = map(object({
    subnets = map(object({
      cidr_block        = string
      availability_zone = string
    }))
  }))
}
####SECURITY_GROUP_FOR_RDS#####
variable "rds_sg" {
  type = map(map(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  })))
}
####SECURITY_GROUP_RULE_ACCESS_RDS#####
variable "ec2stg_to_rds_rule" {
  type = list(object({
    type      = string
    from_port = number
    to_port   = number
    protocol  = string
  }))
}
variable "fargateprod_to_rds_rule" {
  type = list(object({
    type      = string
    from_port = number
    to_port   = number
    protocol  = string
  }))
}
####DATABASE#####
variable "db_instance_storage" {
  type = number
}
variable "db_instance_engine" {
  type = string
}
variable "db_instance_engine_version" {
  type = string
}
variable "db_instance_class" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "backup_retention_period" {
  type = number
}
variable "multi_az" {
  type = bool
}
variable "storage_encrypted" {
  type = bool
}
####SECURITY_GROUP_FOR_VPC_ENDPOINT#####
variable "vpce_sg" {
  type = map(map(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  })))
}