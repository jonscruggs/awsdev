output "s3_state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "S3 state bucket name"
}

output "dynamodb_state_lock_table_name" {
  value       = aws_dynamodb_table.state_lock.id
  description = "Dynamodb state lock table name"
}

# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.app_vpc.id
}

# Network


output "aws_acm_certificate_id" {
  description = "Cert ID"
  value       = aws_acm_certificate.cert.id
}

output "aws_acm_certificate_arn" {
  description = "Cert ARN"
  value       = aws_acm_certificate.cert.arn
}