# ============================================================================
# ECS SERVICES MODULE
# ============================================================================

# Frontend Task Definition
resource "aws_ecs_task_definition" "fe" {
  family                   = "${var.project}-${var.env}-fe"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  memory                   = "128"

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([{
    name                 = "fe"
    image                = var.fe_image
    essential            = true
    force_new_deployment = true
    portMappings = [{
      containerPort = var.fe_container_port
      hostPort      = var.fe_container_port
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.cloudwatch_log_group_name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "fe"
      }
    }
  }])

  lifecycle {
    create_before_destroy = true
  }
}

# Backend Task Definition
resource "aws_ecs_task_definition" "be" {
  family                   = "${var.project}-${var.env}-be"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  memory                   = "256"

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([{
    name      = "be"
    image     = var.be_image
    essential = true
    portMappings = [{
      containerPort = var.be_container_port
      hostPort      = var.be_container_port
      protocol      = "tcp"
    }]

    environment = concat(
      [
        for k, v in var.be_env : { name = k, value = v }
      ],
      var.db_primary_address != "" ? [
        {
          name  = "ConnectionStrings__Default"
          value = "Server=${var.db_primary_address};Port=${var.db_port};Database=${var.db_name};User=${var.db_username};Password=${var.db_password};SslMode=Preferred;"
        }
      ] : []
    )

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.cloudwatch_log_group_name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "be"
      }
    }
  }])

  lifecycle {
    create_before_destroy = true
  }
}

# Frontend Service
resource "aws_ecs_service" "fe" {
  name            = "${var.project}-${var.env}-fe"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.fe.arn
  desired_count   = var.fe_desired_count
  launch_type     = "EC2"

  force_new_deployment = true

  network_configuration {
    subnets         = var.private_app_subnets
    security_groups = [var.ecs_security_group_id]
  }

  load_balancer {
    target_group_arn = var.fe_target_group_arn
    container_name   = "fe"
    container_port   = var.fe_container_port
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  # Spread tasks across AZs and instances
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }
}

# Backend Service
resource "aws_ecs_service" "be" {
  name            = "${var.project}-${var.env}-be"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.be.arn
  desired_count   = var.be_desired_count
  launch_type     = "EC2"

  force_new_deployment = true

  network_configuration {
    subnets         = var.private_app_subnets
    security_groups = [var.ecs_security_group_id]
  }

  load_balancer {
    target_group_arn = var.be_target_group_arn
    container_name   = "be"
    container_port   = var.be_container_port
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  # Spread tasks across AZs and instances
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }
}
