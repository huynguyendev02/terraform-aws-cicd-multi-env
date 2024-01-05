resource "aws_placement_group" "placement_group" {
  name = var.placement_group_name
  strategy = var.placement_group_strategy
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "asg" {
  name = var.asg_name

  min_size                  = var.min_size_asg
  max_size                  = var.max_size_asg
  desired_capacity          = var.desired_capacity_asg

  health_check_type         = var.health_check_type
  target_group_arns = var.target_group_arns

  placement_group = aws_placement_group.placement_group.id
  vpc_zone_identifier       =  var.vpc_zone_identifier
  
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
  lifecycle {
    ignore_changes = all
  }
  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }
}
