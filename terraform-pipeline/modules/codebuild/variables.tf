variable "name" {}
variable "description" {}
variable "service_role_arn" {}

variable "build_source_type" {}
variable "buildspec_path" {}

variable "cache_type" {}
variable "cache_modes" {
    default = null
}
variable "cache_location" {
    default = null
}

variable "artifacts_type" {}

variable "environment_type" {}
variable "environment_compute_type" {}
variable "environment_image" {}
variable "environment_image_pull_type" {}
variable "environment_privileged_mode" {}



