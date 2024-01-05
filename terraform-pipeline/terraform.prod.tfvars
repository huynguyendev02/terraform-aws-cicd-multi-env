prod_project_name = "huyng14-aps-1-p-petclinic"
#####SECURITY_GROUP#####
prod_alb_sg = {
  "inbound" = {
    "httpgreen" = {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "httpblue" = {
      port        = 81
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
prod_fargate_sg = {
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
prod_alb_to_fargate_rule = [{
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
}]
####LOAD_BALANCER#####
prod_alb_listener = {
  httpgreen = {
    port     = 80
    protocol = "HTTP"
    forward = {
      target_group_key = "green"
    }
  }
  httpblue = {
    port     = 81
    protocol = "HTTP"
    forward = {
      target_group_key = "blue"
    }
  }
  https = {
    port     = 443
    protocol = "HTTPS"
    certificate_arn = "arn:aws:acm:ap-southeast-1:816722035531:certificate/8e2bd9fe-4219-4a96-a0e9-3f2a01ee56a6"
    forward = {
      target_group_key = "green"
    }
  }
}

prod_alb_target_groups = {
  green = {
    name             = "tg-bg1-huyng14-aps-1-p-petclinic"
    protocol         = "HTTP"
    port             = 80
    target_type      = "ip"
  }
  blue = {
    name             = "tg-bg2-huyng14-aps-1-p-petclinic"
    protocol         = "HTTP"
    port             = 80
    target_type      = "ip"
  }
}
####IAM Policy & Role#####
prod_ecstaskexec_assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  }
prod_ecstask_assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  }