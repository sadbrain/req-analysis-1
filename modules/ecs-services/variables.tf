variable "project" { type = string }
variable "env" { type = string }
variable "aws_region" { type = string }
variable "ecs_cluster_id" { type = string }
variable "private_app_subnets" { type = list(string) }
variable "ecs_security_group_id" { type = string }

variable "ecs_task_execution_role_arn" { type = string }
variable "cloudwatch_log_group_name" { type = string }

variable "fe_image" { type = string }
variable "fe_container_port" { type = number }
variable "fe_desired_count" { type = number }
variable "fe_target_group_arn" { type = string }

variable "be_image" { type = string }
variable "be_container_port" { type = number }
variable "be_desired_count" { type = number }
variable "be_target_group_arn" { type = string }
variable "be_env" {
  type    = map(string)
  default = {}
}

# RDS connection info for dynamic connection strings
variable "db_primary_address" {
  type        = string
  description = "RDS primary address (hostname only)"
  default     = ""
}

variable "db_port" {
  type        = number
  description = "Database port"
  default     = 3306
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = ""
}

variable "db_username" {
  type        = string
  description = "Database username"
  sensitive   = true
  default     = ""
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
  default     = ""
}
