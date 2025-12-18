# ============================================================================
# SQS VARIABLES
# ============================================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN for SQS access"
  type        = string
}

variable "critical_sns_topic_arn" {
  description = "SNS topic ARN for critical alarms"
  type        = string
}

variable "business_sns_topic_arn" {
  description = "SNS topic ARN for business alarms"
  type        = string
}

# SQS Configuration
variable "delay_seconds" {
  description = "Time in seconds that delivery of messages is delayed"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Maximum message size in bytes (max 256KB)"
  type        = number
  default     = 262144  # 256 KB
}

variable "message_retention_seconds" {
  description = "Number of seconds SQS retains a message (max 14 days)"
  type        = number
  default     = 345600  # 4 days
}

variable "receive_wait_time_seconds" {
  description = "Time for long polling (0-20 seconds)"
  type        = number
  default     = 20
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for messages"
  type        = number
  default     = 30
}

variable "max_receive_count" {
  description = "Max receives before moving to DLQ"
  type        = number
  default     = 3
}

variable "dlq_message_retention_seconds" {
  description = "DLQ message retention (14 days)"
  type        = number
  default     = 1209600  # 14 days
}
