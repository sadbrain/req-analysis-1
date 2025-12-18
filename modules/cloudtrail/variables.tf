# ============================================================================
# CLOUDTRAIL VARIABLES
# ============================================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "security_sns_topic_arn" {
  description = "SNS topic ARN for security alerts"
  type        = string
}

variable "multi_region_trail" {
  description = "Enable multi-region trail"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 90
}
