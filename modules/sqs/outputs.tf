# ============================================================================
# SQS OUTPUTS
# ============================================================================

output "queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.main.url
}

output "queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.main.arn
}

output "queue_name" {
  description = "SQS queue name"
  value       = aws_sqs_queue.main.name
}

output "dlq_url" {
  description = "SQS DLQ URL"
  value       = aws_sqs_queue.dlq.url
}

output "dlq_arn" {
  description = "SQS DLQ ARN"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "SQS DLQ name"
  value       = aws_sqs_queue.dlq.name
}
