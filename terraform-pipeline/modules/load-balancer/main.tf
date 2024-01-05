resource "aws_lb" "alb" {
  name = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_sg
  enable_deletion_protection = false

  # Filter only public subnets for ALB placement
  subnets = var.subnets

  enable_cross_zone_load_balancing = true
  idle_timeout                       = 60

  tags = {
    Name = var.name
  }
}

resource "aws_lb_target_group" "alb_tg" {
  for_each = var.target_groups
  name     = each.value.name
  target_type = each.value.target_type
  port        = each.value.port
  protocol    = each.value.protocol

  health_check {
    enabled = true
    matcher = "200-399"
    path = "/"
  }

  vpc_id   = var.vpc_id
  deregistration_delay = 10
  tags = {
    Name = each.value.name
  }
}

resource "aws_lb_listener" "alb_listener" {
  for_each = var.listeners
  
  load_balancer_arn = aws_lb.alb.arn
  port     = each.value.port 
  protocol = each.value.protocol
  certificate_arn = try(each.value.certificate_arn, null)


  dynamic "default_action" {
    for_each = try([each.value.forward], [])
    content {
      order            = try(default_action.value.order, null)
      target_group_arn = try(aws_lb_target_group.alb_tg[each.value.forward.target_group_key].arn,null)
      type             = "forward"
    }
  }

  depends_on = [ aws_lb_target_group.alb_tg ]
}
