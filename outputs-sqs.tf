# ============================================================================
# SQS OUTPUTS
# ============================================================================

output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = module.sqs.queue_url
}

output "sqs_queue_arn" {
  description = "SQS queue ARN"
  value       = module.sqs.queue_arn
}

output "sqs_dlq_url" {
  description = "SQS DLQ URL"
  value       = module.sqs.dlq_url
}
