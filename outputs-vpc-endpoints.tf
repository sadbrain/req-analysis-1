# ============================================================================
# VPC ENDPOINTS OUTPUTS
# ============================================================================

output "sqs_endpoint_id" {
  description = "SQS VPC endpoint ID"
  value       = module.vpc_endpoints.sqs_endpoint_id
}

output "s3_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = module.vpc_endpoints.s3_endpoint_id
}
