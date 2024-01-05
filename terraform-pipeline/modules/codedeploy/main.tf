resource "aws_codedeploy_app" "app" {
  name             = var.app_name
  compute_platform = var.app_platform
}

resource "aws_codedeploy_deployment_group" "group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = var.deployment_group_name
  deployment_config_name = var.deployment_config_name
  service_role_arn      = var.deployment_group_role_arn

  deployment_style {
    deployment_option = var.deployment_option
    deployment_type   = var.deployment_type
  }
  
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = var.deployment_ready_action_timeout
    }

    green_fleet_provisioning_option {
      action = var.green_fleet_provisioning_action
    }

    terminate_blue_instances_on_deployment_success {
      action = var.terminate_blue_instance_action
    }
  }

  dynamic "ecs_service" {
    for_each = var.ecs_cluster_name != null ? [1] : []
    content {
      cluster_name = var.ecs_cluster_name
      service_name = var.ecs_service_name
    }
  }

  autoscaling_groups = var.autoscaling_groups
  load_balancer_info {
    
    dynamic "target_group_info" {
      for_each = var.target_group_name
      content {
        name = target_group_info.value
      }
    }
    dynamic "target_group_pair_info" {
      for_each = var.ecs_prod_traffic_route != null ? [1] : []
      content {
        prod_traffic_route {
          listener_arns = [var.ecs_prod_traffic_route]
        }

        dynamic "target_group" {
          for_each = var.ecs_target_group
          content {
            name = target_group.value
          }
        }
      }
    }

    dynamic "target_group_info" {
      for_each = var.target_group_name
      content {
        name = target_group_info.value
      }
    }
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to desired_capacity
      autoscaling_groups,
    ]
  }
  
}