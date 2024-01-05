resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "task" {
  family = var.task_name
  container_definitions = jsonencode([{
    name      = var.container_name,
    image     = var.container_image,
    essential = true,

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    },
    portMappings = [
      {
        "containerPort" : var.container_port # Application Port
      }
    ],
    secrets = var.container_secrets
  }])
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode # Stating that we are using ECS Fargate # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.memory    # Specifying the memory our container requires
  cpu                      = var.cpu     # Specifying the CPU our container requires
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn 
}


resource "aws_ecs_service" "service" {
  name                               = var.ecs_service_name
  cluster                            = aws_ecs_cluster.cluster.id
  task_definition                    = aws_ecs_task_definition.task.arn
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  launch_type                        = var.ecs_service_launch_type
  scheduling_strategy                = var.ecs_service_scheduling_strategy
  desired_count                      = var.ecs_service_desired_count


  force_new_deployment = var.ecs_service_force_new_deployment
  load_balancer {
    target_group_arn = var.ecs_service_target_group_arn
    container_name   = var.container_name 
    container_port   =  var.container_port # Application Port
  }
  deployment_controller {
    type = var.ecs_service_deployment_controller_type
  }

  network_configuration {
    subnets = var.ecs_service_subnets
    security_groups = var.ecs_service_security_groups
  }


  lifecycle {
    ignore_changes = all
  }

  depends_on = [aws_ecs_cluster.cluster]
}

