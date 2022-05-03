terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region  = "us-east-1"
  profile = "iamadmin-general"
}


# Create KMS policy for cloudwatch logs to use the key above
# Limit it to the specific couldwatch group made below
# { "Version": "2012-10-17", "Id": "key-default-1", "Statement": [ { "Sid": "Enable IAM User Permissions", "Effect": "Allow", "Principal": { "AWS": "arn:aws:iam::Your_account_ID:root" }, "Action": "kms:*", "Resource": "*" },
#         {"Effect": "Allow",
#             "Principal": {"Service": "logs.region.amazonaws.com"},
#             "Action": [
#                 "kms:Encrypt*",
#                 "kms:Decrypt*",
#                 "kms:ReEncrypt*",
#                 "kms:GenerateDataKey*",
#                 "kms:Describe*"],
#             "Resource": "*",
#             "Condition": {"ArnEquals": {"kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:region:account-id:log-group:log-group-name"}
#             }
#         }  ] }



resource "aws_cloudwatch_log_group" "session-logs" {
  name = "session-logs"
  retention_in_days = 30
  kms_key_id = aws_kms_key.session-logs.arn
}

resource "aws_kms_key" "session-logs" {
  description             = "SSM Session Logging CloudWatch Group"
  policy = templatefile("session-log-key-policy.json.tpl",{
      account = data.aws_caller_identity.current.account_id
      log-group = "session-logs" #aws_cloudwatch_log_group.session-logs.name
      region = data.aws_region.current.name
  })
}

resource "aws_ssm_document" "SSM-SessionManagerRunShell" {
  name            = "SSM-SessionManagerRunShell"
  document_format = "JSON"
  document_type   = "Session"
  content = templatefile("SessionManagerRunShell.json",{
      logGroupName = aws_cloudwatch_log_group.session-logs.name
      kmsKeyId = aws_kms_key.session-logs.arn

  })
#   content = <<DOC
# {
#     "schemaVersion": "1.0",
#     "description": "Document to hold regional settings for Session Manager",
#     "sessionType": "Standard_Stream",
#     "inputs": {
#       "s3BucketName": "",
#       "s3KeyPrefix": "",
#       "s3EncryptionEnabled": true,
#       "cloudWatchLogGroupName": "sm-session-logging",
#       "cloudWatchEncryptionEnabled": false,
#       "cloudWatchStreamingEnabled": true,
#       "idleSessionTimeout": "20",
#       "maxSessionDuration": "68",
#       "kmsKeyId": "",
#       "runAsEnabled": false,
#       "runAsDefaultUser": "",
#       "shellProfile": {
#         "windows": "",
#         "linux": ""
#       }
#     }
#   }
# DOC
}

output "KMS" { 
value = aws_kms_key.session-logs.arn
}