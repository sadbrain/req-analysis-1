variable "project" { type = string }
variable "env" { type = string }
variable "vpc_id" { type = string }
variable "private_db_subnets" { type = list(string) }
variable "db_security_group_id" { type = string }

variable "db_engine" { type = string }
variable "db_engine_version" { type = string }
variable "db_instance_class" { type = string }
variable "db_allocated_storage" { type = number }
variable "db_name" { type = string }
variable "db_master_username" { type = string }
variable "db_master_password" {
  type      = string
  sensitive = true
}
variable "db_port" { type = number }
variable "db_backup_retention_days" { type = number }
