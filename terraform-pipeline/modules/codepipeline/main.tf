resource "aws_codepipeline" "pipeline" {
  name     = var.name
  role_arn = var.pipeline_role_arn
  
  artifact_store {
    location = var.artifact_store_location
    type     = var.artifact_store_type
  }

   dynamic "stage" {
    for_each = var.stages

    content {
      name = "Stage-${stage.value["name"]}"
      action {
        category         = stage.value["category"]
        name             = "Action-${stage.value["name"]}"
        owner            = stage.value["owner"]
        provider         = stage.value["provider"]
        input_artifacts  = try(stage.value["input_artifacts"],[])
        output_artifacts = try(stage.value["output_artifacts"],[])
        version          = "1"

        configuration = stage.value["configuration"]
      }
    }
  }
  tags = {
    Name = var.name
  }
}