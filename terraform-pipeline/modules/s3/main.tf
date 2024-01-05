resource "aws_s3_bucket" "s3" {
  bucket = var.name
  force_destroy = true
  tags = {
    Name = var.name
  }
}