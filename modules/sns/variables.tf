# ============================================================================
# SNS VARIABLES
# ============================================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "critical_alarm_emails" {
  description = "Email addresses for CRITICAL alarms (24/7 - downtime, health checks)"
  type        = list(string)
  default     = []
}

variable "business_alarm_emails" {
  description = "Email addresses for BUSINESS alarms (work hours - performance, optimization)"
  type        = list(string)
  default     = []
}

variable "security_alert_emails" {
  description = "Email addresses for SECURITY alerts (CloudTrail, audit events)"
  type        = list(string)
  default     = []
}
