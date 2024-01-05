variable "pipe_project_name" {
  type = string
}
####ECR#####
variable "pipe_image_tag_mutability" {
  type = string
}
variable "pipe_scan_on_push" {
  type = bool
}
####DEFAULT_JAVA_VERSION####
variable "pipe_default_java_version" {
  type = any
}
variable "pipe_default_maven_version" {
  type = any
}
####IAM####
variable "pipe_iam_policy_codepipeline" {
  type = any
}
variable "pipe_codepipeline_assume_role_policy" {
  type = any
}
####CODECOMMIT#####
variable "pipe_default_branch" {
  type = string
}
####CODEBUILD#####
variable "pipe_build_source_type" {
  type = string
}
variable "pipe_stg_buildspec_path" {
  type = string
}
variable "pipe_prod_buildspec_path" {
  type = string
}
variable "pipe_cache_type" {
  type = string
}
variable "pipe_cache_modes" {
  type = list(string)
  default = null
}
variable "pipe_artifacts_type" {
  type = string
}
variable "pipe_environment_type" {
  type = string
}
variable "pipe_environment_compute_type" {
  type = string
}
variable "pipe_environment_image" {
  type = string
}
variable "pipe_environment_image_pull_type" {
  type = string
}