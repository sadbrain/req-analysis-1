# ============================================================================
# ELASTICACHE REDIS OUTPUTS
# ============================================================================

output "redis_endpoint" {
  description = "Redis primary endpoint address"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint address"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.redis.port
}

output "redis_configuration_endpoint" {
  description = "Redis configuration endpoint (for cluster mode)"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

output "redis_security_group_id" {
  description = "Security group ID for Redis"
  value       = aws_security_group.redis.id
}

output "redis_arn" {
  description = "ARN of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.redis.arn
}
