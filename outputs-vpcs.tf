output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = local.public_subnets
}

output "private_app_subnets" {
  description = "Private app subnet IDs"
  value       = local.private_app_subnets
}

output "private_db_subnets" {
  description = "Private DB subnet IDs"
  value       = local.private_db_subnets
}