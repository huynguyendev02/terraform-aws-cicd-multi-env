stg_project_name = "huyng14-aps-1-s-petclinic"
####SECURITY_GROUP#####
stg_alb_sg = {
  "inbound" = {
    "http" = {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "https" = {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  },
  "outbound" = {
    "all" = {
      port        = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
stg_ec2_sg = {
  "inbound"  = {},
  "outbound" = {
    "all" = {
      port        = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
####SECURITY_GROUP_RULE#####
stg_alb_to_ec2_rule = [{
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
}]
####LOAD_BALANCER#####
stg_alb_listener = {
  http = {
    port     = 80
    protocol = "HTTP"
    forward = {
      target_group_key = "tg"
    }
  }
  https = {
    port     = 443
    protocol = "HTTPS"
    certificate_arn = "arn:aws:acm:ap-southeast-1:816722035531:certificate/8e2bd9fe-4219-4a96-a0e9-3f2a01ee56a6"
    forward = {
      target_group_key = "tg"
    }
  }
}

stg_alb_target_groups = {
  tg = {
    name             = "tg-huyng14-aps-1-d-petclinic"
    protocol         = "HTTP"
    port             = 80
    target_type      = "instance"
  }
}
####COMPUTE#####
stg_ami = "ami-01c6f3d2318619ecb"
stg_instance_type = "t2.micro"
stg_volume_size = 8
stg_volume_type = "gp3"
stg_associate_public_ip_address = false
####ASG#####
stg_min_size_asg = 1
stg_max_size_asg = 1
stg_desired_capacity_asg = 1
stg_health_check_type = "ELB"
stg_placement_group_strategy = "spread"