output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "alb_url_fe" {
  description = "Frontend URL"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_url_be" {
  description = "Backend URL"
  value       = "http://${module.alb.alb_dns_name}:8080"
}