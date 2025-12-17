variable "db_engine" {
  type        = string
  description = "Database engine type"
  default     = "mysql"
}

variable "db_engine_version" {
  type        = string
  description = "Database engine version"
  default     = "8.0"
}

variable "db_instance_class" {
  type        = string
  description = "Database instance class"
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
  default     = 20
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_master_username" {
  type        = string
  description = "Database master username"
  sensitive   = true
}

variable "db_master_password" {
  type        = string
  description = "Database master password"
  sensitive   = true
}

variable "db_port" {
  type        = number
  description = "Database port"
  default     = 3306
}

variable "db_backup_retention_days" {
  type        = number
  description = "Number of days to retain backups"
  default     = 7
}
