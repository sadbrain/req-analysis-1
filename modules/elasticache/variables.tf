# ============================================================================
# ELASTICACHE REDIS VARIABLES
# ============================================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ElastiCache"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "Security groups allowed to access Redis (e.g., ECS security group)"
  type        = list(string)
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

variable "node_type" {
  description = "ElastiCache node instance type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Number of cache nodes (min 2 for Multi-AZ)"
  type        = number
  default     = 2
}

variable "parameter_group_name" {
  description = "ElastiCache parameter group name"
  type        = string
  default     = "default.redis7"
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain automatic snapshots"
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "Daily time range for snapshots (UTC)"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Weekly time range for maintenance (UTC)"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit (requires auth token)"
  type        = bool
  default     = false
}

variable "auth_token" {
  description = "Auth token for Redis (required if transit encryption is enabled)"
  type        = string
  default     = ""
  sensitive   = true
}
