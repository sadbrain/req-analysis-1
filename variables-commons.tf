variable "project" {
  type        = string
  description = "Project/system name used for resource naming and tagging"
}

variable "env" {
  type        = string
  description = "Environment name (dev/stg/prod, etc.)"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "aws_profile" { type = string }

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH access"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged into default tags"
  default     = {}
}