variable "app_name" {}
variable "app_platform" {}
variable "deployment_group_name" {}
variable "deployment_config_name" {}
variable "deployment_group_role_arn" {}
variable "deployment_option" {}
variable "deployment_type" {}
variable "deployment_ready_action_timeout" {}
variable "green_fleet_provisioning_action" {
  default = null
}
variable "terminate_blue_instance_action" {}
variable "autoscaling_groups" {
  default = null
}
variable "target_group_name" {
  default = []
}

variable "ecs_cluster_name" {
  default = null
  
}
variable "ecs_service_name" {
  default = null

}
variable "ecs_prod_traffic_route" {
  default = null

}
variable "ecs_target_group" {
  default = []

}




