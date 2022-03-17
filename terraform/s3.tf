# S3 bucker for codebuild
resource "aws_s3_bucket" "codebuild-s3" {
  bucket = "demo-codebuild-s3-${var.env}"
  acl    = "private"
  # Enable versioning in bucket
  versioning {
    enabled = true
  }
  # S3 policy for delete
  lifecycle_rule {
    id      = "Delete after 3 days"
    enabled = true
    expiration {
      days = 3
    }
  }

  tags = {
    Name        = "Demo-codebuild-s3-${var.env}"
    Environment = var.env
  }
}

# TFstate s3
resource "aws_s3_bucket" "terraform_state" {
  bucket = "demo-tfstate-s3-${var.env}"
  # Enable versioning
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
