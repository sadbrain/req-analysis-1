resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.env}-db-subnets"
  subnet_ids = local.private_db_subnets
}

resource "aws_db_instance" "primary" {
  identifier = "${var.project}-${var.env}-db"

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage

  db_name  = var.db_name
  username = var.db_master_username
  password = var.db_master_password
  port     = var.db_port

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  publicly_accessible        = false
  multi_az                   = false
  backup_retention_period    = var.db_backup_retention_days
  skip_final_snapshot        = true
  deletion_protection        = false
  auto_minor_version_upgrade = true
}

resource "aws_db_instance" "read_replica" {
  identifier = "${var.project}-${var.env}-db-replica"

  replicate_source_db = aws_db_instance.primary.arn
  instance_class      = var.db_instance_class

  publicly_accessible        = false
  skip_final_snapshot        = true
  deletion_protection        = false
  auto_minor_version_upgrade = true

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
}
