# ============================================================================
# SNS / CLOUDWATCH VARIABLES
# ============================================================================

variable "critical_alarm_emails" {
  description = "Email addresses for CRITICAL alarms (24/7 - downtime, health)"
  type        = list(string)
  default     = []
}

variable "business_alarm_emails" {
  description = "Email addresses for BUSINESS alarms (work hours - performance)"
  type        = list(string)
  default     = []
}

variable "security_alert_emails" {
  description = "Email addresses for SECURITY alerts (CloudTrail, audit)"
  type        = list(string)
  default     = []
}
