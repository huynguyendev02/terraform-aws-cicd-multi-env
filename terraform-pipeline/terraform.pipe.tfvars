pipe_project_name = "huyng14-aps-1-pipe-petclinic"
####ECR#####
pipe_image_tag_mutability = "MUTABLE"
pipe_scan_on_push = false
####DEFAULT_JAVA_VERSION####
pipe_default_java_version = {
  name = "/PETCLINIC_PIPELINE/JAVA_VERSION"
  type = "String"
  value = "17"
}
pipe_default_maven_version = {
  name = "/PETCLINIC_PIPELINE/MAVEN_VERSION"
  type = "String"
  value = "3.9.5"
}
####IAM####
pipe_iam_policy_codepipeline = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
pipe_codepipeline_assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  }

####CODECOMMIT#####
pipe_default_branch = "master"
####CODEBUILD#####
pipe_build_source_type = "CODEPIPELINE"
#Staging
pipe_stg_buildspec_path = "./codepipeline/buildspec_stg.yml"
#Production
pipe_prod_buildspec_path = "./codepipeline/buildspec_prod.yml"
pipe_cache_type = "S3"

pipe_artifacts_type = "CODEPIPELINE"

pipe_environment_type = "LINUX_CONTAINER"
pipe_environment_compute_type = "BUILD_GENERAL1_SMALL"
pipe_environment_image = "aws/codebuild/standard:5.0"
pipe_environment_image_pull_type = "CODEBUILD"
