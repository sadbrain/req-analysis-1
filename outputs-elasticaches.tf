output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = module.elasticache.redis_endpoint
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint"
  value       = module.elasticache.redis_reader_endpoint
}

output "redis_port" {
  description = "Redis port"
  value       = module.elasticache.redis_port
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = module.elasticache.redis_security_group_id
}
