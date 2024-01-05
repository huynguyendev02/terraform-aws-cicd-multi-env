variable "prod_project_name" {
  type = string
}

####SECURITY_GROUP#####
variable "prod_alb_sg" {
  type = map(map(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  })))
}
variable "prod_fargate_sg" {
  type = any
}
variable "prod_alb_to_fargate_rule" {
  type = any
}
####LOAD_BALANCER#####
variable "prod_alb_listener" {
  type = any
}
variable "prod_alb_target_groups" {
  type = any
}
####IAM Policy & Role#####
variable "prod_ecstask_assume_role_policy" {
  type = any
}
variable "prod_ecstaskexec_assume_role_policy" {
  type = any
}