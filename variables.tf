variable "project" {
  type        = string
  description = "Project/system name used for resource naming and tagging"
}

variable "env" {
  type        = string
  description = "Environment name (dev/stg/prod, etc.)"
}

variable "aws_profile" { type = string }

variable "tags" {
  type        = map(string)
  description = "Additional tags merged into default tags"
  default     = {}
}
