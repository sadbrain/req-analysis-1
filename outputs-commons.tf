output "connection_info" {
  description = "Quick connection information"
  value = {
    frontend_url = "http://${module.alb.alb_dns_name}"
    backend_url  = "http://${module.alb.alb_dns_name}:8080"
    nat_ips      = module.nat.nat_public_ips
    cluster      = module.ecs_cluster.cluster_name
  }
}