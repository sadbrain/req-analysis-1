output "cloudfront_domain_name" {
  description = "CloudFront domain name (use this for access)"
  value       = module.cloudfront.cloudfront_domain_name
}

output "cloudfront_url" {
  description = "CloudFront URL"
  value       = "https://${module.cloudfront.cloudfront_domain_name}"
}