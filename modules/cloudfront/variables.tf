variable "project" { type = string }
variable "env" { type = string }

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name"
}

variable "alb_arn" {
  type        = string
  description = "ALB ARN for VPC Origin"
}

variable "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name for assets (images, PDFs, videos)"
  type        = string
  default     = ""
}

variable "s3_oac_id" {
  description = "S3 Origin Access Control ID"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domain (must be in us-east-1)"
  type        = string
  default     = ""
}

variable "domain_names" {
  description = "List of domain names for CloudFront aliases"
  type        = list(string)
  default     = []
}
