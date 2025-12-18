output "rds_primary_endpoint" {
  description = "RDS primary endpoint"
  value       = module.rds.primary_endpoint
  sensitive   = true
}

# output "rds_replica_endpoint" {
#   description = "RDS replica endpoint"
#   value       = module.rds.replica_endpoint
#   sensitive   = true
# }