# ============================================================================
# AWS BACKUP VARIABLES
# ============================================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN to backup"
  type        = string
}

variable "critical_sns_topic_arn" {
  description = "SNS topic ARN for critical alerts"
  type        = string
}

# Daily backup configuration
variable "daily_backup_schedule" {
  description = "Cron expression for daily backup (default: 3 AM UTC)"
  type        = string
  default     = "cron(0 3 * * ? *)"
}

variable "daily_retention_days" {
  description = "Daily backup retention in days"
  type        = number
  default     = 7
}

# Weekly backup configuration
variable "weekly_backup_schedule" {
  description = "Cron expression for weekly backup (default: Sunday 3 AM UTC)"
  type        = string
  default     = "cron(0 3 ? * SUN *)"
}

variable "weekly_retention_days" {
  description = "Weekly backup retention in days"
  type        = number
  default     = 30
}

# Monthly backup configuration
variable "monthly_backup_schedule" {
  description = "Cron expression for monthly backup (default: 1st of month 3 AM UTC)"
  type        = string
  default     = "cron(0 3 1 * ? *)"
}

variable "monthly_retention_days" {
  description = "Monthly backup retention in days"
  type        = number
  default     = 365
}
