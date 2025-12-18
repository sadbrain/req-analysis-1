# ============================================================================
# VPC ENDPOINTS MODULE
# ============================================================================
# Enables private communication from ECS to AWS services without internet

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project}-${var.env}-vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTPS from ECS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-vpc-endpoints-sg"
  }
}

# ============================================================================
# INTERFACE ENDPOINTS (com.amazonaws.<region>.service)
# ============================================================================

# SQS Endpoint
resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true

  tags = {
    Name = "${var.project}-${var.env}-sqs-endpoint"
  }
}

# ECR API Endpoint (for pulling Docker images)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true

  tags = {
    Name = "${var.project}-${var.env}-ecr-api-endpoint"
  }
}

# ECR DKR Endpoint (for Docker registry operations)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true

  tags = {
    Name = "${var.project}-${var.env}-ecr-dkr-endpoint"
  }
}

# CloudWatch Logs Endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true

  tags = {
    Name = "${var.project}-${var.env}-logs-endpoint"
  }
}

# SSM Endpoint (for Parameter Store - maintenance mode)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true

  tags = {
    Name = "${var.project}-${var.env}-ssm-endpoint"
  }
}

# ============================================================================
# GATEWAY ENDPOINTS (no additional charges)
# ============================================================================

# S3 Gateway Endpoint (for ECR image layers and assets bucket)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = {
    Name = "${var.project}-${var.env}-s3-endpoint"
  }
}

# DynamoDB Gateway Endpoint (optional, for future use)
resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = {
    Name = "${var.project}-${var.env}-dynamodb-endpoint"
  }
}
