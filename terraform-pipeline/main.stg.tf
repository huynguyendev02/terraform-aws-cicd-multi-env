#Create Security Groups
module "stg-alb-security-group" {
  source       = "./modules/security-group"

  create_sg = true
  name = "alb-sg-${var.stg_project_name}"
  description = "Security Group for ALB"
  sg_rules_main = var.stg_alb_sg
  vpc = module.network.vpc

  providers = {
    aws = aws.stg
  }
}
module "stg-ec2-security-group" {
  source       = "./modules/security-group"

  create_sg = true
  name = "ec2-sg-${var.stg_project_name}"
  description = "Security Group for EC2"
  sg_rules_main = var.stg_ec2_sg
  vpc = module.network.vpc

  providers = {
    aws = aws.stg
  }
}
module "stg-alb-to-ec2-security-group-rules" {
  source       = "./modules/security-group"

  create_sg = false
  security_group_id = module.stg-ec2-security-group.sg_id
  source_security_group_id = module.stg-alb-security-group.sg_id
  sg_rules = var.stg_alb_to_ec2_rule

  providers = {
    aws = aws.stg
  }
}
#Create Load Balancer
module "stg-alb" {
  source       = "./modules/load-balancer"

  name = "alb-sg-${var.stg_project_name}"
  vpc_id = module.network.vpc.id
  subnets =  [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "public")]
  alb_sg = [module.stg-alb-security-group.sg_id]
  listeners = var.stg_alb_listener
  target_groups = var.stg_alb_target_groups

  providers = {
    aws = aws.stg
  }
}
#Create IAM Policy to access S3 & Secret Manager
module "stg-iam-policy-access-s3-secret" {
  source  = "./modules/iam-policy"

  name = "policy-s3-secret${var.stg_project_name}"
  description = "Policy for accessing a specific S3 bucket and AWS Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3::*:codepipeline-*",
          "arn:aws:s3::*:codepipeline-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets"
        ]
        Resource = module.database-secret.secret.arn
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:DescribeParameters",
          "ssm:GetParametersByPath",
          "ssm:GetParameter"
        ],
        Resource = [
          "arn:aws:ssm:*:*:parameter/PETCLINIC_PIPELINE/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:*"
        ],
        Resource = [
          "*" 
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codedeploy-commands-secure:*",
          "codedeploy:*"
        ],
        Resource = [
          "*" 
        ]
      }
    ]
  })

  providers = {
    aws = aws.stg
  }
}
#Create IAM Role with Policy
module "stg-ec2-iam-role" {
  source  = "./modules/iam-role"

  name = "ec2-iam-role-${var.stg_project_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  policy_arn = module.stg-iam-policy-access-s3-secret.policy.arn

  providers = {
    aws = aws.stg
  }
}
#Create EC2 Instance Profile
module "stg-ec2-instance-profile" {
  source  = "./modules/iam-instance-profile"

  name = "ec2-instance-profile-${var.stg_project_name}"
  iam_role_name = module.stg-ec2-iam-role.iam-role.name

  providers = {
    aws = aws.stg
  }
}
#Create Launch Template
module "stg-compute" {
  source  = "./modules/compute"

  ec2_key_name = "ssh-${var.stg_project_name}"
  ec2_public_key = file("./key/id_rsa.pub")

  launch_template_name = "lt-${var.stg_project_name}"
  ami = var.stg_ami
  instance_type = var.stg_instance_type
  iam_instance_profile_name = module.stg-ec2-instance-profile.profile.name
  volume_size = var.stg_volume_size
  volume_type = var.stg_volume_type

  associate_public_ip_address = var.stg_associate_public_ip_address
  security_groups = [module.stg-ec2-security-group.sg_id]

  tag_specifications = {
    Name = "ec2-${var.stg_project_name}"
  }

  providers = {
    aws = aws.stg
  }
}


module "stg-ec2-asg" {
  source  = "./modules/autoscaling-group"

  placement_group_name = "placement-group-${var.stg_project_name}"
  placement_group_strategy = var.stg_placement_group_strategy

  asg_name = "asg-${var.stg_project_name}"
  min_size_asg = var.stg_min_size_asg
  max_size_asg                  = var.stg_max_size_asg
  desired_capacity_asg          = var.stg_desired_capacity_asg
  health_check_type = var.stg_health_check_type
  target_group_arns = [for tg in module.stg-alb.target_groups : tg.arn]
  vpc_zone_identifier = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "private")]
  launch_template_id = module.stg-compute.launch_template.id

  providers = {
    aws = aws.stg
  }
}