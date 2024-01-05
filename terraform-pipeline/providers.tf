terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.24.0"
    }
  }
}

provider "aws" {
  alias  = "pipe"
  region = "ap-southeast-1"
  default_tags {
    tags = {
      Project = var.project_tag
      Owner = var.owner_tag
      Environment = "Pipeline"
      CreatedBy = "Terraform"
    }
  }
}
provider "aws" {
  alias  = "stg"
  region = "ap-southeast-1"
  default_tags {
    tags = {
      Project = var.project_tag
      Owner = var.owner_tag
      Environment = "Staging"
      CreatedBy = "Terraform"
    }
  }
}


provider "aws" {
  alias  = "prod"
  region = "ap-southeast-1"
  default_tags {
    tags = {
      Project = var.project_tag
      Owner = var.owner_tag
      Environment = "Production"
      CreatedBy = "Terraform"
    }
  }
}