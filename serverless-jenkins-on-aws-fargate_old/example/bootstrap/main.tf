data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name

  tags = {
    team     = "devops"
    solution = "jenkins"
  }
}

resource "aws_s3_bucket" "this" {
  bucket = var.state_bucket_name
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

# Allows all services to log to bucket
module "aws_logs" {
  source         = "trussworks/logs/aws"
  s3_bucket_name = "scruggs-xyz-aws-logs"
}

resource "aws_dynamodb_table" "this" {
  name = var.state_lock_table_name
  hash_key = "LockID"
  billing_mode     = "PAY_PER_REQUEST"
 
  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
 
  # tags {
  #   Name = "DynamoDB Terraform State Lock Table"
  # }
}

resource "aws_ssm_parameter" "secret" {
  name        = "jenkins-pwd"
  description = "Jenkins Password"
  type        = "SecureString"
  value       = "jenkinspassword123"

  tags = {
    environment = "dev"
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "jenkins-controller.scruggs.xyz"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}
