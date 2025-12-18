# ============================================================================
# CLOUDTRAIL OUTPUTS
# ============================================================================

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = aws_cloudtrail.main.id
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_s3_bucket" {
  description = "S3 bucket name for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_log_group_name" {
  description = "CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "CloudWatch Log Group ARN"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}
