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

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name
  force_destroy = true
  tags = local.tags
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

# Allows all services to log to bucket
module "aws_logs" {
  source         = "trussworks/logs/aws"
  s3_bucket_name = "scruggs-xyz-aws-logs-${random_id.id.hex}"
}

resource "aws_dynamodb_table" "state_lock" {
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
