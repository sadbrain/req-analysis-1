# ============================================================================
# RDS MODULE
# ============================================================================

resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.env}-db-subnets"
  subnet_ids = var.private_db_subnets

  tags = {
    Name = "${var.project}-${var.env}-db-subnets"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "primary" {
  identifier = "${var.project}-${var.env}-db"

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = false

  db_name  = var.db_name
  username = var.db_master_username
  password = var.db_master_password
  port     = var.db_port

  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  publicly_accessible = false
  multi_az            = false
  #   backup_retention_period    = var.db_backup_retention_days
  #   backup_window              = "03:00-04:00"
  #   maintenance_window         = "mon:04:00-mon:05:00"
  skip_final_snapshot        = true
  final_snapshot_identifier  = null
  deletion_protection        = false
  auto_minor_version_upgrade = true

  enabled_cloudwatch_logs_exports = []

  tags = {
    Name = "${var.project}-${var.env}-db-primary"
  }

  lifecycle {
    ignore_changes = [password]
  }
}

# resource "aws_db_instance" "read_replica" {
#   identifier = "${var.project}-${var.env}-db-replica"

#   replicate_source_db = aws_db_instance.primary.identifier
#   instance_class      = var.db_instance_class

#   publicly_accessible        = false
#   skip_final_snapshot        = true
#   deletion_protection        = false
#   auto_minor_version_upgrade = true

#   vpc_security_group_ids = [var.db_security_group_id]

#   tags = {
#     Name = "${var.project}-${var.env}-db-replica"
#   }

#   depends_on = [aws_db_instance.primary]
# }
