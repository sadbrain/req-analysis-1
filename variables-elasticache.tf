# ============================================================================
# ELASTICACHE VARIABLES
# ============================================================================

variable "elasticache_engine_version" {
  description = "Redis engine version"
  type        = string
}

variable "elasticache_node_type" {
  description = "ElastiCache node instance type"
  type        = string
}

variable "elasticache_num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
}

variable "elasticache_parameter_group_name" {
  description = "ElastiCache parameter group name"
  type        = string
}

variable "elasticache_snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
}

variable "elasticache_snapshot_window" {
  description = "Daily snapshot time window (UTC)"
  type        = string
}

variable "elasticache_maintenance_window" {
  description = "Weekly maintenance time window (UTC)"
  type        = string
}

variable "elasticache_transit_encryption_enabled" {
  description = "Enable in-transit encryption"
  type        = bool
}
