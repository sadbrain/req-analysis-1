variable "project" { type = string }
variable "env" { type = string }
variable "ecs_cluster_name" { type = string }
variable "ecs_cluster_id" { type = string }
variable "private_app_subnets" { type = list(string) }
variable "ecs_security_group_id" { type = string }
variable "key_name" { type = string }

variable "ecs_instance_type" { type = string }
variable "ecs_desired_capacity" { type = number }
variable "ecs_min_size" { type = number }
variable "ecs_max_size" { type = number }