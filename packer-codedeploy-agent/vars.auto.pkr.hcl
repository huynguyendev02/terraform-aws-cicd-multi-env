variable "ami_name" {
    default = "codedeploy-ubuntu-huyng14"
}
variable "region" {
    default = "ap-southeast-1"
}
variable "project_name" {
    default = "huyng14-aps-1-d-pipeline"
}
variable "project_tag" {
    default = "Pipeline-HuyNG14"
}
variable "owner_tag" {
    default = "HuyNG14-Terraform"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "source_ami_name" {
    default = "ami-078c1149d8ad719a7"
}
variable "ssh_username" {
    default = "ubuntu"
}