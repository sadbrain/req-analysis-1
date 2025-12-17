variable "alb_listener_port_fe" {
  type        = number
  description = "ALB listener port for frontend"
  default     = 80
}

variable "alb_listener_port_be" {
  type        = number
  description = "ALB listener port for backend"
  default     = 8080
}

variable "alb_healthcheck_path_fe" {
  type        = string
  description = "Health check path for frontend"
  default     = "/"
}

variable "alb_healthcheck_path_be" {
  type        = string
  description = "Health check path for backend"
  default     = "/"
}