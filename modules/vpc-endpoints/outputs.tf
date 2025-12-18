# ============================================================================
# VPC ENDPOINTS OUTPUTS
# ============================================================================

output "sqs_endpoint_id" {
  description = "SQS VPC endpoint ID"
  value       = aws_vpc_endpoint.sqs.id
}

output "ecr_api_endpoint_id" {
  description = "ECR API VPC endpoint ID"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "ECR DKR VPC endpoint ID"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "logs_endpoint_id" {
  description = "CloudWatch Logs VPC endpoint ID"
  value       = aws_vpc_endpoint.logs.id
}

output "ssm_endpoint_id" {
  description = "SSM VPC endpoint ID"
  value       = aws_vpc_endpoint.ssm.id
}

output "s3_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoints_security_group_id" {
  description = "Security group ID for VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
