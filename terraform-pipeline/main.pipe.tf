#####Create ECR for petclinic
module "pipe-ecr-petclinic" {
  source       = "./modules/ecr"
  
  name = "ecr-petclinic-${var.pipe_project_name}"
  image_tag_mutability = var.pipe_image_tag_mutability
  scan_on_push = var.pipe_scan_on_push

  providers = {
    aws = aws.pipe
  }
}
#####Create Paramater Store for ECR
module "pipe-ecr-url-ssm" {
  source = "./modules/ssm-parameter"
  parameter = {
    name = "/PETCLINIC_PIPELINE/ECR_URL"
    type = "String"
    value = module.pipe-ecr-petclinic.ecr.repository_url
  }

  providers = {
    aws = aws.pipe
  }
}
#####Create S3 Bucket for Artifacts
module "pipe-s3-artifacts-bucket" {
  source                = "./modules/s3"
  
  name = "codepipeline-artifacts-${var.pipe_project_name}"

  providers = {
    aws = aws.pipe
  }
}
module "pipe-s3-cache-bucket" {
  source                = "./modules/s3"
  
  name = "codepipeline-cache-${var.pipe_project_name}"

  providers = {
    aws = aws.pipe
  }
}
#####Create Paramater Store for JAVA & Maven Version
module "pipe-java-version-ssm" {
  source = "./modules/ssm-parameter"
  parameter = var.pipe_default_java_version

  providers = {
    aws = aws.pipe
  }
}
module "pipe-maven-version-ssm" {
  source = "./modules/ssm-parameter"
  parameter = var.pipe_default_maven_version

  providers = {
    aws = aws.pipe
  }
}
#####Create IAM Policy for CodePipeline
module "pipe-iam-policy-codepipeline" {
  source  = "./modules/iam-policy"

  name = "policy-codepipeline-${var.pipe_project_name}"
  description = "Policy for CodePipeline with S3 bucket and AWS Secrets Manager"
  policy = jsonencode(var.pipe_iam_policy_codepipeline)

  providers = {
    aws = aws.pipe
  }
}
#####Create IAM Role for CodePipeline with policy
module "pipe-codepipeline-iam-role" {
  source  = "./modules/iam-role"

  name = "codepipeline-iam-role-${var.pipe_project_name}"
  assume_role_policy = jsonencode(var.pipe_codepipeline_assume_role_policy)
  policy_arn = module.pipe-iam-policy-codepipeline.policy.arn

  providers = {
    aws = aws.pipe
  }
}
#####Create CodeCommit VCS
module "pipe-codecommit-source-repo" {
  source       = "./modules/codecommit"

  name = "codecommit-${var.pipe_project_name}"
  description = "Repo for Petclinic source code"
  default_branch = var.pipe_default_branch
  providers = {
    aws = aws.pipe
  }
}
#####Create CodeBuild project for Staging environment
module "pipe-stg-codebuild-petclinic" {
  source       = "./modules/codebuild"

  name = "stg-codebuild-${var.pipe_project_name}"
  description = "Build for Petclinic (Staging Environment)"
  service_role_arn = module.pipe-codepipeline-iam-role.iam-role.arn

  build_source_type = var.pipe_build_source_type
  buildspec_path = var.pipe_stg_buildspec_path

  cache_type = var.pipe_cache_type
  cache_location = module.pipe-s3-cache-bucket.s3.bucket

  artifacts_type = var.pipe_artifacts_type

  environment_type = var.pipe_environment_type
  environment_compute_type = var.pipe_environment_compute_type
  environment_image = var.pipe_environment_image
  environment_image_pull_type = var.pipe_environment_image_pull_type
  environment_privileged_mode = true

  providers = {
    aws = aws.pipe
  }
}
#####Create CodeBuild project for Production environment
module "pipe-prod-codebuild-petclinic" {
  source       = "./modules/codebuild"

  name = "prod-codebuild-${var.pipe_project_name}"
  description = "Build for Petclinic (Production Environment)"
  service_role_arn = module.pipe-codepipeline-iam-role.iam-role.arn

  build_source_type = var.pipe_build_source_type
  buildspec_path = var.pipe_prod_buildspec_path

  cache_type = var.pipe_cache_type
  cache_location = module.pipe-s3-cache-bucket.s3.bucket

  artifacts_type = var.pipe_artifacts_type

  environment_type = var.pipe_environment_type
  environment_compute_type = var.pipe_environment_compute_type
  environment_image = var.pipe_environment_image
  environment_image_pull_type = var.pipe_environment_image_pull_type
  environment_privileged_mode = true

  providers = {
    aws = aws.pipe
  }
}
#####Create CodeDeploy for Staging environment
module "pipe-stg-codedeploy-petclinic" {
  source = "./modules/codedeploy"

  app_name = "stg-codedeploy-app-${var.pipe_project_name}"
  app_platform = "Server"

  deployment_group_name = "codedeploy-group-${var.pipe_project_name}"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_group_role_arn = module.pipe-codepipeline-iam-role.iam-role.arn

  deployment_option = "WITH_TRAFFIC_CONTROL"
  deployment_type = "BLUE_GREEN"

  deployment_ready_action_timeout = "CONTINUE_DEPLOYMENT"
  green_fleet_provisioning_action = "COPY_AUTO_SCALING_GROUP"
  terminate_blue_instance_action = "TERMINATE"

  autoscaling_groups = [module.stg-ec2-asg.asg.name]
  target_group_name = values(module.stg-alb.target_groups)[*].name

  providers = {
    aws = aws.pipe
  }
}
#####Create CodeDeploy for Production environment
module "pipe-prod-codedeploy-petclinic" {
  source = "./modules/codedeploy"

  app_name = "prod-codedeploy-app-${var.pipe_project_name}"
  app_platform = "ECS"

  deployment_group_name = "codedeploy-group-${var.pipe_project_name}"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_role_arn = module.pipe-codepipeline-iam-role.iam-role.arn

  deployment_option = "WITH_TRAFFIC_CONTROL"
  deployment_type = "BLUE_GREEN"

  deployment_ready_action_timeout = "CONTINUE_DEPLOYMENT"
  terminate_blue_instance_action = "TERMINATE"

  ecs_cluster_name = module.prod-ecs-petclinic.cluster.name
  ecs_service_name = module.prod-ecs-petclinic.service.name
  ecs_prod_traffic_route = module.prod-alb.lb_listener["https"].arn
  ecs_target_group = [module.prod-alb.target_groups["green"].name, module.prod-alb.target_groups["blue"].name]

  providers = {
    aws = aws.pipe
  }
}
#####Create CodePipeline
module "pipe-codepipeline-petclinic" {
  source       = "./modules/codepipeline"

  name = "codepipeline-${var.pipe_project_name}"
  pipeline_role_arn = module.pipe-codepipeline-iam-role.iam-role.arn

  artifact_store_type = "S3"
  artifact_store_location = module.pipe-s3-artifacts-bucket.s3.bucket
  stages = [
    { 
      name = "Source", 
      category = "Source", 
      owner = "AWS", 
      provider = "CodeCommit",  
      output_artifacts = ["SourceOutput"],
      configuration = {
        RepositoryName = module.pipe-codecommit-source-repo.repo.repository_name
        BranchName = var.pipe_default_branch
        PollForSourceChanges = "true"
      }
    },
    { 
      name = "Staging-Build", 
      category = "Build", 
      owner = "AWS", 
      provider = "CodeBuild",  
      input_artifacts = ["SourceOutput"],
      output_artifacts = ["StgAppspecScripts"],
      configuration = {
        ProjectName = module.pipe-stg-codebuild-petclinic.codebuild.name
      }
    },
    { 
      name = "Staing-Deploy", 
      category = "Deploy", 
      owner = "AWS", 
      provider = "CodeDeploy",  
      input_artifacts = ["StgAppspecScripts"],
      configuration = {
        ApplicationName = module.pipe-stg-codedeploy-petclinic.codedeploy.name
        DeploymentGroupName = module.pipe-stg-codedeploy-petclinic.codedeploy_group.deployment_group_name
      }
    },
    { 
      name = "Approve-Production", 
      category = "Approval", 
      owner = "AWS", 
      provider = "Manual",  
      configuration = {
        CustomData = "Please review the changes in Staging Env and Approve"
        NotificationArn = module.sns-topic.sns_topic.arn
      }
    },
    { 
      name = "Production-Build", 
      category = "Build", 
      owner = "AWS", 
      provider = "CodeBuild",  
      input_artifacts = ["SourceOutput"],
      output_artifacts = ["ProdAppspecScripts"],
      configuration = {
        ProjectName = module.pipe-prod-codebuild-petclinic.codebuild.name
      }
    },
    { 
      name = "Production-Deploy", 
      category = "Deploy", 
      owner = "AWS", 
      provider = "CodeDeploy",  
      input_artifacts = ["ProdAppspecScripts"],
      configuration = {
        ApplicationName = module.pipe-prod-codedeploy-petclinic.codedeploy.name
        DeploymentGroupName = module.pipe-prod-codedeploy-petclinic.codedeploy_group.deployment_group_name
      }
    }
  ]

  providers = {
    aws = aws.pipe
  }
}

