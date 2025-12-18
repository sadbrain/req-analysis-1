# ============================================================================
# AWS BACKUP MODULE - RDS Aurora Backup
# ============================================================================

# Backup vault
resource "aws_backup_vault" "main" {
  name = "${var.project}-${var.env}-backup-vault"

  tags = {
    Name = "${var.project}-${var.env}-backup-vault"
  }
}

# Backup plan
resource "aws_backup_plan" "s3" {
  name = "${var.project}-${var.env}-s3-backup-plan"

  # Daily backup at 3 AM UTC
  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.daily_backup_schedule

    lifecycle {
      delete_after = var.daily_retention_days
    }

    recovery_point_tags = {
      Name = "${var.project}-${var.env}-daily-backup"
      Type = "Daily"
    }
  }

  # Weekly backup (Sunday) - kept longer
  rule {
    rule_name         = "weekly-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.weekly_backup_schedule

    lifecycle {
      delete_after = var.weekly_retention_days
    }

    recovery_point_tags = {
      Name = "${var.project}-${var.env}-weekly-backup"
      Type = "Weekly"
    }
  }

  # Monthly backup (1st of month) - kept longest
  rule {
    rule_name         = "monthly-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.monthly_backup_schedule

    lifecycle {
      delete_after = var.monthly_retention_days
    }

    recovery_point_tags = {
      Name = "${var.project}-${var.env}-monthly-backup"
      Type = "Monthly"
    }
  }

  tags = {
    Name = "${var.project}-${var.env}-s3-backup-plan"
  }
}

# IAM role for AWS Backup
resource "aws_iam_role" "backup" {
  name = "${var.project}-${var.env}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })
}

# Attach AWS managed backup policy
resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Backup selection - S3 Assets Bucket
resource "aws_backup_selection" "s3" {
  name         = "${var.project}-${var.env}-s3-selection"
  plan_id      = aws_backup_plan.s3.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [
    var.s3_bucket_arn
  ]
}

# CloudWatch alarm for failed backups
resource "aws_cloudwatch_metric_alarm" "backup_failed" {
  alarm_name          = "${var.project}-${var.env}-backup-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfBackupJobsFailed"
  namespace           = "AWS/Backup"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "CRITICAL: AWS Backup job has failed"
  alarm_actions       = [var.critical_sns_topic_arn]

  dimensions = {
    BackupVaultName = aws_backup_vault.main.name
  }
}
