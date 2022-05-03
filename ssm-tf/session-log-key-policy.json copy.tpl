{
    "Version": "2012-10-17",
       "Id": "{$log-group}-policy",
       "Statement": [
            {
                "Sid": "Enable IAM User Permissions",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::${account}:root"
                },
                "Action": "kms:*",
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ssm.amazonaws.com"
                },
                "Action": [
                    "kms:Encrypt*",
                    "kms:Decrypt*",
                    "kms:ReEncrypt*",
                    "kms:GenerateDataKey*",
                    "kms:CreateGrant",
                    "kms:ListGrants",
                    "kms:Describe*"
                ],
                "Resource": "*"
            },    
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "logs.amazonaws.com"
                },
                "Action": [
                    "kms:Encrypt*",
                    "kms:Decrypt*",
                    "kms:ReEncrypt*",
                    "kms:GenerateDataKey*",
                    "kms:Describe*"
                ],
                "Resource": "*",
                "Condition": {
                    "ArnEquals": {
                        "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${region}:${account}:log-group:${log-group}"
                    }
                }
            }    
       ]
}  