
# Create an event rule to execute everyday at midnight
resource "aws_cloudwatch_event_rule" "splunk-backupconfig" {
  name                = "splunk-backupconfig"
  description         = "Backup $SPUNK_HOME/etc to S3 nightly"
  schedule_expression = "cron(* * * * ? *)"
}

# Create an event to execute backup command via SSM, limit to EC2 instances 
# that are tagged SplunkCluster.  The command assumes the EC2 instance has 
# an instance IAM role that allows access to the target S3 bucket
resource "aws_cloudwatch_event_target" "splunk-backupconfig" {
  target_id = "splunk-backupconfig"
  arn       = "arn:aws:ssm:${var.region}::document/AWS-RunShellScript"
  input     = "{\"commands\":[\"sudo tar cvzf - /tmp | aws s3 cp - s3://scruggs-splunk/SplunkConfigBackup-$HOSTNAME-$(date +%m-%d-%Y).tar.gz\"]}"
  rule      = aws_cloudwatch_event_rule.splunk-backupconfig.name
  role_arn  = aws_iam_role.service-splunk-backup.arn

  run_command_targets {
    key    = "tag:Role"
    values = ["SplunkCluster"]
  }
}

# Create policy to allow AWS Events to execute SSM commands 
data "aws_iam_policy_document" "splunk_backup_policy" {
  statement {
    actions = [
      "ssm:SendCommand"
    ]

    resources = [
      "arn:aws:ec2:us-west-2:095262149203:instance/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/*"
      values = [
        "SplunkCluster"
      ]
    }
  }

  statement {
    actions = [
      "ssm:SendCommand"
    ]

    resources = [
      "arn:aws:ssm:us-west-2:*:document/AWS-RunShellScript"
    ]
  }
}

# Create assume role policy for AWS Events
data "aws_iam_policy_document" "splunk_backup_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

# Create IAM role, use assume role policy document created above
resource "aws_iam_role" "service-splunk-backup" {
  name               = "service-splunk-backup"
  assume_role_policy = data.aws_iam_policy_document.splunk_backup_assume_policy.json
}

# Create IAM policy, use policy document created above
resource "aws_iam_policy" "splunk-backup" {
  name        = "splunk-backup-policy"
  description = "Splunk Backup Policy"
  policy      = data.aws_iam_policy_document.splunk_backup_policy.json
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "splunk-backup" {
  role       = aws_iam_role.service-splunk-backup.name
  policy_arn = aws_iam_policy.splunk-backup.arn
}
