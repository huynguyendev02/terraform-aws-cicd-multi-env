resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.ec2_key_name
  public_key = var.ec2_public_key
  tags = {
    Name = var.ec2_key_name
  }
}

resource "aws_launch_template" "launch_template" {
  name = var.launch_template_name

  image_id = var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.ec2_key_pair.key_name
  

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups = var.security_groups
  }
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  tag_specifications {
    resource_type = "instance"
    tags = var.tag_specifications
  }

  tags = {
    Name = var.launch_template_name
  }

}

