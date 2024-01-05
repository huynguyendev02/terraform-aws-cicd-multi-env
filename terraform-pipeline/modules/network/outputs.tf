output "vpc" {
  value = aws_vpc.vpc
}
output "subnet" {
  value = aws_subnet.subnet
}
output "private_route_table" {
  value = aws_route_table.private-route-table
}