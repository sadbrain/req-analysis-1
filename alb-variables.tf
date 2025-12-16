variable "alb_healthcheck_path_fe" {
  type    = string
  default = "/"
}

variable "alb_healthcheck_path_be" {
  type    = string
  default = "/"
}

variable "alb_listener_port_fe" {
  type    = number
  default = 80
}

variable "alb_listener_port_be" {
  type    = number
  default = 8080
}