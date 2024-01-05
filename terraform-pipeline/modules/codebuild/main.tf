resource "aws_codebuild_project" "project" {
  name           = var.name
  description    = var.description

  service_role = var.service_role_arn

  source {
    type            = var.build_source_type
    buildspec       = var.buildspec_path
  }

  cache {
    type  = var.cache_type
    modes = var.cache_modes
    location = var.cache_location
  }

  artifacts {
    type = var.artifacts_type
  }
  environment {
    type                        = var.environment_type
    compute_type                = var.environment_compute_type
    image                       = var.environment_image
    image_pull_credentials_type = var.environment_image_pull_type
    privileged_mode = var.environment_privileged_mode
  }

  
  tags = {
    Name = var.name
  }
}