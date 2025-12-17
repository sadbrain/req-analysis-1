output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs_cluster.cluster_id
}

output "fe_service_name" {
  description = "Frontend service name"
  value       = module.ecs_services.fe_service_name
}

output "be_service_name" {
  description = "Backend service name"
  value       = module.ecs_services.be_service_name
}