variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "alb_listener_port_fe" {
  type = number
}

variable "alb_listener_port_be" {
  type = number
}

variable "fe_container_port" {
  type = number
}

variable "be_container_port" {
  type = number
}

variable "db_port" {
  type = number
}
