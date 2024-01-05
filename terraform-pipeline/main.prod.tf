#Create Security Groups for ALB ECS
module "prod-fargate-security-group" {
  source       = "./modules/security-group"

  create_sg = true
  name = "fargate-sg-${var.stg_project_name}"
  description = "Security Group for Fargate"
  sg_rules_main = var.prod_fargate_sg
  vpc = module.network.vpc

  providers = {
    aws = aws.prod
  }
}
module "prod-alb-security-group" {
  source       = "./modules/security-group"

  create_sg = true
  name = "alb-sg-${var.prod_project_name}"
  description = "Security Group for ALB"
  sg_rules_main = var.prod_alb_sg
  vpc = module.network.vpc

  providers = {
    aws = aws.prod
  }
}
module "prod-alb-to-fargate-security-group-rules" {
  source       = "./modules/security-group"

  create_sg = false
  security_group_id = module.prod-fargate-security-group.sg_id
  source_security_group_id = module.prod-alb-security-group.sg_id
  sg_rules = var.prod_alb_to_fargate_rule

  providers = {
    aws = aws.prod
  }
}
#Create Load Balancer
module "prod-alb" {
  source       = "./modules/load-balancer"

  name = "alb-sg-${var.prod_project_name}"
  vpc_id = module.network.vpc.id
  subnets =  [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "public")]
  alb_sg = [module.prod-alb-security-group.sg_id]
  listeners = var.prod_alb_listener
  target_groups = var.prod_alb_target_groups

  providers = {
    aws = aws.prod
  }
}
#Create IAM Policy for ECS Task
module "prod-ecs-task-iam-policy" {
  source  = "./modules/iam-policy"

  name = "policy-ecs-task-${var.stg_project_name}"
  description = "Policy for accessing AWS Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets"
        ]
        Resource = module.database-secret.secret.arn
      },
    ]
  })

  providers = {
    aws = aws.prod
  }
}
#Create IAM Policy for ECS Task Exec
module "prod-ecs-taskexec-iam-policy" {
  source  = "./modules/iam-policy"

  name = "policy-ecs-taskexec-${var.stg_project_name}"
  description = "Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets"
        ]
        Resource = module.database-secret.secret.arn
      },
      {
        Effect = "Allow"
        Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })

  providers = {
    aws = aws.prod
  }
}
#####Create IAM Role for ECS Task Execution
module "prod-ecs-taskexec-iam-role" {
  source  = "./modules/iam-role"

  name = "ecs-taskexec-iam-role-${var.prod_project_name}"
  assume_role_policy = jsonencode(var.prod_ecstaskexec_assume_role_policy)
  policy_arn = module.prod-ecs-taskexec-iam-policy.policy.arn

  providers = {
    aws = aws.prod
  }
}
#####Create IAM Role for ECS Task 
module "prod-ecs-task-iam-role" {
  source  = "./modules/iam-role"

  name = "ecs-task-iam-role-${var.prod_project_name}"
  assume_role_policy = jsonencode(var.prod_ecstask_assume_role_policy)
  policy_arn = module.prod-ecs-task-iam-policy.policy.arn

  providers = {
    aws = aws.prod
  }
}
#Create CloudWatch Log Group
module "prod-ecs-task-log-group" {
  source       = "./modules/cloudwatch-log"

  name = "/ecs/task-log-group-${var.prod_project_name}"

  providers = {
    aws = aws.prod
  }
}
#Create ECS Cluster and Task Definition
module "prod-ecs-petclinic" {
  source       = "./modules/ecs"
  
  ecs_cluster_name = "ecs-${var.prod_project_name}"

  task_name = "ecs-task-${var.prod_project_name}"
  container_name = "ecs-container-${var.prod_project_name}"
  container_image = "${module.pipe-ecr-petclinic.ecr.repository_url}:latest"
  container_port = 8080

  container_secrets = [
    {
      name      = "MYSQL_URL",
      valueFrom = "${module.database-secret.secret.arn}:JDBC_CONNECTION_STRING::"
    },
    {
      name      = "MYSQL_USER",
      valueFrom = "${module.database-secret.secret.arn}:USERNAME::"
    },
    {
      name      = "MYSQL_PASS",
      valueFrom = "${module.database-secret.secret.arn}:PASSWORD::"
    }
  ]

  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  memory                   = 1024   
  cpu                      = 512  
  execution_role_arn = module.prod-ecs-taskexec-iam-role.iam-role.arn
  task_role_arn = module.prod-ecs-task-iam-role.iam-role.arn

  ecs_service_name = "ecs-service-${var.prod_project_name}"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200
  health_check_grace_period_seconds = 300
  ecs_service_launch_type = "FARGATE"
  ecs_service_scheduling_strategy = "REPLICA"
  ecs_service_desired_count = 1
  ecs_service_force_new_deployment = true
  ecs_service_deployment_controller_type = "CODE_DEPLOY"

  ecs_service_subnets = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "private")]
  ecs_service_security_groups = [module.prod-fargate-security-group.sg_id]
  ecs_service_target_group_arn =  values(module.prod-alb.target_groups)[1].arn

  log_group = module.prod-ecs-task-log-group.log_group.name
  region = "ap-southeast-1"

  depends_on = [
    module.prod-ecs-task-iam-role,
    module.prod-alb,
    module.prod-alb-security-group,
    module.prod-ecs-task-log-group
  ]
  providers = {
    aws = aws.prod
  }
}
#Create SNS Topic to send alert
module "sns-topic" {
  source = "./modules/sns"
  sns_topic_name = "sns-topic-${var.prod_project_name}"
  sns_topic_protocol = "email"
  sns_topic_endpoint = "huynguyendev02@gmail.com"
}

#Create CloudWatch Alarm check Back-end die
module "prod-alarm-backend-die" {
  source = "./modules/cloudwatch-alarm"
  cloudwatch_alarm_name = "alarm-backend-${var.prod_project_name}"
  cloudwatch_alarm_description = "This metric checks if the running task count falls below 1"
  cloudwatch_alarm_metric_name = "RunningTaskCount"
  cloudwatch_alarm_namespace = "AWS/ECS"
  cloudwatch_alarm_period = "60"
  cloudwatch_alarm_statistic = "SampleCount"
  cloudwatch_alarm_threshold = "1"
  cloudwatch_alarm_comparison_operator = "LessThanThreshold"
  cloudwatch_alarm_evaluation_periods = "2"
  cloudwatch_alarm_alarm_actions = [module.sns-topic.sns_topic.arn]
  cloudwatch_alarm_dimensions = {
    ClusterName = "ecs-${var.prod_project_name}"
    ServiceName = "ecs-service-${var.prod_project_name}"
  }
  depends_on = [
    module.sns-topic
  ]
}
#Create CloudWatch Alarm check High CPU
module "prod-alarm-high-cpu" {
  source = "./modules/cloudwatch-alarm"
  cloudwatch_alarm_name = "alarm-cpu-${var.prod_project_name}"
  cloudwatch_alarm_description = "This metric checks if CPU utilization exceeds 80 percent"
  cloudwatch_alarm_metric_name = "CPUUtilization"
  cloudwatch_alarm_namespace = "AWS/ECS"
  cloudwatch_alarm_period = "60"
  cloudwatch_alarm_statistic = "Average"
  cloudwatch_alarm_threshold = "80"
  cloudwatch_alarm_comparison_operator = "GreaterThanThreshold"
  cloudwatch_alarm_evaluation_periods = "2"
  cloudwatch_alarm_alarm_actions = [module.sns-topic.sns_topic.arn]
  cloudwatch_alarm_dimensions = {
    ClusterName = "ecs-${var.prod_project_name}"
    ServiceName = "ecs-service-${var.prod_project_name}"
  }
  depends_on = [
    module.sns-topic
  ]
}
#Create IAM Policy for Lambda to ECS
module "prod-lambda-ecs-iam-policy" {
  source  = "./modules/iam-policy"

  name = "policy-lambda-ecs-${var.prod_project_name}"
  description = "Policy for Lambda to ECS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = "*"
      },
    ]
  })

  providers = {
    aws = aws.prod
  }
}
#Create IAM Role for Lambda with Policy
module "prod-lambda-iam-role" {
  source  = "./modules/iam-role"

  name = "lambda-iam-role-${var.prod_project_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  policy_arn = module.prod-lambda-ecs-iam-policy.policy.arn

  providers = {
    aws = aws.prod
  }
}

module "prod-lambda-cronjob" {
  source = "./modules/lambda"

  filename      = "${path.module}/cronjob.zip"
  function_name = "lambda-cronjob-${var.prod_project_name}"
  role          = module.prod-lambda-iam-role.iam-role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"


  lambda_permission_statement_id  = "AllowExecutionFromCloudWatch"
  lambda_permission_action        = "lambda:InvokeFunction"
  lambda_permission_principal     = "events.amazonaws.com"
  lambda_permission_source_arn = "arn:aws:events:${var.region}:${var.account_id}:*"

  environment_variables = {
    CLUSTER_NAME = "ecs-${var.prod_project_name}"
    SERVICE_NAME = "ecs-service-${var.prod_project_name}"
  }

  providers = {
    aws = aws.prod
  }
}

module "prod-cronjob-event" {
  source = "./modules/cloudwatch-event"

  schedule_expression = "cron(0 18,7 * * ? *)"
  name                = "event-lambda-cronjob-${var.prod_project_name}"
  description         = "Triggers every day at 18:00 and 07:00"

  target_arn       = module.prod-lambda-cronjob.function.arn

  providers = {
    aws = aws.prod
  }
}