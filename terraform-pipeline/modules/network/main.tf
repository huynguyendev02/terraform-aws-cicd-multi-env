resource "aws_vpc" "vpc" {
    cidr_block       = var.network_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    instance_tenancy = "default"
    tags = {
        Name = "vpc-${var.project_name}"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-${var.project_name}"
  }
}

locals {
  network_subnets = flatten([
    for subnet_type, network in var.networks : [
      for subnet_name, subnet in network.subnets : {
        subnet_type = subnet_type
        subnet_name  = subnet_name
        subnet_cidr_block  = subnet.cidr_block
        availability_zone = subnet.availability_zone
      }
    ]
  ])
}

resource "aws_subnet" "subnet" {
  for_each = {
    for subnet in local.network_subnets : "${subnet.subnet_type}.${subnet.subnet_name}" => subnet
  }

  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value.subnet_cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = join("-",[each.value.subnet_name, var.project_name])
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block = var.network_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "public-route-${var.project_name}"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.network_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "private-route-${var.project_name}"
  }
}

resource "aws_route_table_association" "route-table-assocation" {
  subnet_id      = each.value.id
  route_table_id = strcontains(each.value.tags.Name, "public")  ? aws_route_table.public-route-table.id : aws_route_table.private-route-table.id
  for_each = aws_subnet.subnet
}