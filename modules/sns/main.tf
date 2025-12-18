# ============================================================================
# SNS MODULE - Notification Topics
# ============================================================================

# SNS Topic for CRITICAL Alarms (24/7 alerts - CPU, Memory, Downtime)
resource "aws_sns_topic" "critical_alarms" {
  name         = "${var.project}-${var.env}-critical-alarms"
  display_name = "CRITICAL Alarms (24/7) - ${var.project} ${var.env}"

  tags = {
    Name = "${var.project}-${var.env}-critical-alarms"
    Type = "Critical"
  }
}

# SNS Topic for BUSINESS Alarms (only during business hours - performance, optimization)
resource "aws_sns_topic" "business_alarms" {
  name         = "${var.project}-${var.env}-business-alarms"
  display_name = "Business Alarms (Work Hours) - ${var.project} ${var.env}"

  tags = {
    Name = "${var.project}-${var.env}-business-alarms"
    Type = "Business"
  }
}

# SNS Topic for Security/Audit Alerts (CloudTrail events)
resource "aws_sns_topic" "security_alerts" {
  name         = "${var.project}-${var.env}-security-alerts"
  display_name = "Security & Audit Alerts - ${var.project} ${var.env}"

  tags = {
    Name = "${var.project}-${var.env}-security-alerts"
    Type = "Security"
  }
}

# Email subscriptions for CRITICAL alarms
resource "aws_sns_topic_subscription" "critical_email" {
  count     = length(var.critical_alarm_emails) > 0 ? length(var.critical_alarm_emails) : 0
  topic_arn = aws_sns_topic.critical_alarms.arn
  protocol  = "email"
  endpoint  = var.critical_alarm_emails[count.index]
}

# Email subscriptions for BUSINESS alarms
resource "aws_sns_topic_subscription" "business_email" {
  count     = length(var.business_alarm_emails) > 0 ? length(var.business_alarm_emails) : 0
  topic_arn = aws_sns_topic.business_alarms.arn
  protocol  = "email"
  endpoint  = var.business_alarm_emails[count.index]
}

# Email subscriptions for SECURITY alerts
resource "aws_sns_topic_subscription" "security_email" {
  count     = length(var.security_alert_emails) > 0 ? length(var.security_alert_emails) : 0
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.security_alert_emails[count.index]
}
