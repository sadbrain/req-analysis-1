# ============================================================================
# CLOUDWATCH ALARMS MODULE - SIMPLIFIED (5 Critical Alarms)
# ============================================================================
# Only essential alarms to minimize costs (~$0.10/alarm/month)
# Total: 5 alarms = ~$0.50/month
# ============================================================================

# ============================================================================
# ALARM 1: ALB Unhealthy Hosts (CRITICAL)
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.project}-${var.env}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "CRITICAL: Unhealthy hosts detected in target groups"
  alarm_actions       = [var.critical_sns_topic_arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# ============================================================================
# ALARM 2: ALB 5XX Errors (CRITICAL)
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project}-${var.env}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "CRITICAL: ALB 5xx errors exceed 10 in 5 minutes"
  alarm_actions       = [var.critical_sns_topic_arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# ============================================================================
# ALARM 3: RDS CPU High (CRITICAL)
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "rds_cpu_critical" {
  alarm_name          = "${var.project}-${var.env}-rds-cpu-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "CRITICAL: RDS CPU > 85% for 15 minutes"
  alarm_actions       = [var.critical_sns_topic_arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_id
  }
}

# ============================================================================
# ALARM 4: RDS Low Memory (CRITICAL)
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "rds_memory_critical" {
  alarm_name          = "${var.project}-${var.env}-rds-memory-critical"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "268435456"  # 256 MB in bytes
  alarm_description   = "CRITICAL: RDS freeable memory < 256 MB"
  alarm_actions       = [var.critical_sns_topic_arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_id
  }
}

# ============================================================================
# ALARM 5: ECS Service Down (CRITICAL)
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "ecs_no_running_tasks" {
  alarm_name          = "${var.project}-${var.env}-ecs-no-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "CRITICAL: No ECS tasks running"
  alarm_actions       = [var.critical_sns_topic_arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
  }
}
