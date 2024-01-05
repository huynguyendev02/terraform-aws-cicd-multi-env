resource "aws_codecommit_repository" "repo" {
  repository_name = var.name
  description     = var.description
  default_branch  = var.default_branch
  tags = {
    Name = var.name
  }
}