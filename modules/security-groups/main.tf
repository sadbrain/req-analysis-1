# ============================================================================
# SECURITY GROUPS MODULE
# ============================================================================

resource "aws_security_group" "alb" {
  name   = "${var.project}-${var.env}-alb"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.alb_listener_port_fe
    to_port     = var.alb_listener_port_fe
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.alb_listener_port_be
    to_port     = var.alb_listener_port_be
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-alb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "nat" {
  name   = "${var.project}-${var.env}-nat"
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  # SSH access for debugging
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Separate rule to avoid circular dependency
resource "aws_security_group_rule" "nat_ingress_from_ecs" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.nat.id
}

resource "aws_security_group" "ecs" {
  name   = "${var.project}-${var.env}-ecs"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.fe_container_port
    to_port         = var.fe_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port       = var.be_container_port
    to_port         = var.be_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow traffic from NAT for internet connectivity
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.nat.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-ecs"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "db" {
  name   = "${var.project}-${var.env}-db"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-db"
  }

  lifecycle {
    create_before_destroy = true
  }
}
