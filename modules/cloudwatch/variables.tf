# ============================================================================
# CLOUDWATCH VARIABLES
# ============================================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "critical_sns_topic_arn" {
  description = "SNS topic ARN for CRITICAL alarms (24/7)"
  type        = string
}

# ALB variables
variable "alb_arn_suffix" {
  description = "ALB ARN suffix for metrics"
  type        = string
}

# RDS variables
variable "rds_cluster_id" {
  description = "RDS cluster identifier"
  type        = string
}

# ECS variables
variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

# CloudFront variable (optional for dashboard)
variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  type        = string
  default     = ""
}
