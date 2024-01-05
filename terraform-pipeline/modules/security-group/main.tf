
resource "aws_security_group" "sg" {
  count = var.create_sg ? 1 : 0

  name = var.name
  description = var.description

  dynamic "ingress" {
    for_each = var.sg_rules_main["inbound"]
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.sg_rules_main["outbound"]
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  vpc_id = var.vpc.id
  tags = {
    Name = var.name
  }
}

resource "aws_security_group_rule" "sg_rule" {
  count                    = length(var.sg_rules)
  
  security_group_id        = var.security_group_id
  source_security_group_id = var.source_security_group_id

  type                     = var.sg_rules[count.index].type
  from_port                = var.sg_rules[count.index].from_port
  to_port                  = var.sg_rules[count.index].to_port
  protocol                 = var.sg_rules[count.index].protocol
}

