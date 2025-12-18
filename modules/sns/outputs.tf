# ============================================================================
# SNS OUTPUTS
# ============================================================================

output "critical_alarms_topic_arn" {
  description = "ARN of CRITICAL alarms SNS topic (24/7)"
  value       = aws_sns_topic.critical_alarms.arn
}

output "business_alarms_topic_arn" {
  description = "ARN of BUSINESS alarms SNS topic (work hours)"
  value       = aws_sns_topic.business_alarms.arn
}

output "security_alerts_topic_arn" {
  description = "ARN of security alerts SNS topic"
  value       = aws_sns_topic.security_alerts.arn
}

output "critical_alarms_topic_name" {
  description = "Name of CRITICAL alarms SNS topic"
  value       = aws_sns_topic.critical_alarms.name
}

output "business_alarms_topic_name" {
  description = "Name of BUSINESS alarms SNS topic"
  value       = aws_sns_topic.business_alarms.name
}

output "security_alerts_topic_name" {
  description = "Name of security alerts SNS topic"
  value       = aws_sns_topic.security_alerts.name
}
