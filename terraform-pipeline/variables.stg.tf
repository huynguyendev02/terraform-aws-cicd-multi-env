variable "stg_project_name" {
    type = string
}
####SECURITY_GROUP#####
variable "stg_alb_sg" {
  type = map(map(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  })))
}
variable "stg_ec2_sg" {
  type = map(map(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  })))
}
####SECURITY_GROUP_RULE#####
variable "stg_alb_to_ec2_rule" {
  type = list(object({
    type      = string
    from_port = number
    to_port   = number
    protocol  = string
  }))
}
####LOAD_BALANCER#####
variable "stg_alb_listener" {
  type = any
}
variable "stg_alb_target_groups" {
  type = any
}
####COMPUTE#####
variable "stg_ami" {
  type = string
}
variable "stg_instance_type" {
  type = string
}
variable "stg_volume_size" {
  type = number
}
variable "stg_volume_type" {
  type = string
}
variable "stg_associate_public_ip_address" {
  type = bool
}
####ASG#####
variable "stg_min_size_asg" {
  type = number
}
variable "stg_max_size_asg" {
  type = number
}
variable "stg_desired_capacity_asg" {
  type = number
}
variable "stg_health_check_type" {
  type = string
}
variable "stg_placement_group_strategy" {
  type = string
}


