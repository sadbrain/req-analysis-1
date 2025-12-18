# ============================================================================
# ELASTICACHE REDIS MODULE
# ============================================================================

# Subnet group for ElastiCache
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project}-${var.env}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project}-${var.env}-redis-subnet-group"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.project}-${var.env}-redis"
  description          = "Redis cluster for ${var.project} ${var.env}"
  
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_nodes
  
  port                 = 6379
  parameter_group_name = var.parameter_group_name
  
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
  
  # Automatic failover (requires at least 2 nodes)
  automatic_failover_enabled = var.num_cache_nodes > 1 ? true : false
  multi_az_enabled           = var.num_cache_nodes > 1 ? true : false
  
  # Backup configuration
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window           = var.snapshot_window
  
  # Maintenance window
  maintenance_window = var.maintenance_window
  
  # At-rest encryption
  at_rest_encryption_enabled = true
  
  # In-transit encryption
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                = var.transit_encryption_enabled ? var.auth_token : null
  
  # Auto minor version upgrade
  auto_minor_version_upgrade = true
  
  tags = {
    Name = "${var.project}-${var.env}-redis"
  }
}

# Security Group for Redis
resource "aws_security_group" "redis" {
  name        = "${var.project}-${var.env}-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-redis-sg"
  }
}
