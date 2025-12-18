variable "project" { type = string }
variable "env" { type = string }

variable "alb_listener_arn" {
  description = "ALB listener ARN to add maintenance rule"
  type        = string
}
