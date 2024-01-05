variable "project_name" {
  type = string
}


variable "network_cidr" {
  type = string
}
variable "networks" {
  type = map(object({
    subnets    = map(object({ 
      cidr_block = string
      availability_zone = string
    }))
  }))
}


