variable "project" { type = string }
variable "env" { type = string }
variable "vpc_id" { type = string }
variable "private_app_subnets" { type = list(string) }
variable "alb_security_group_id" { type = string }

variable "alb_listener_port_fe" { type = number }
variable "alb_listener_port_be" { type = number }
variable "fe_container_port" { type = number }
variable "be_container_port" { type = number }
variable "alb_healthcheck_path_fe" { type = string }
variable "alb_healthcheck_path_be" { type = string }
