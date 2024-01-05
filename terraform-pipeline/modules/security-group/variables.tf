variable "create_sg" {
    default = true
}
####SECURITY_GROUP#####
variable "name" {
    default = null
}
variable "description" {
    default = null
}
variable "sg_rules_main" {
    default = {
        inbound  = []
        outbound = []
    }
}
####SECURITY_GROUP_RULE#####
variable "security_group_id" {
    default = null
}
variable "source_security_group_id" {
    default = null
}
variable "sg_rules" {
    default = []
}
####EXTERNAL#####
variable "vpc" {
    default = null
}
