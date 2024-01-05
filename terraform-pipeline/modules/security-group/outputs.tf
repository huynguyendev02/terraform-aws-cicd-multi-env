output "sg_id" {
  value = try(aws_security_group.sg[0].id,"")
}
