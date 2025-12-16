resource "aws_ecs_task_definition" "fe" {
  family                   = "${var.project}-${var.env}-fe"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  # cpu                      = "256"
  # memory                   = "512"
  memory                   = "128"

  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name         = "fe"
    image        = var.fe_image
    essential    = true
    portMappings = [{ containerPort = var.fe_container_port, "hostPort": var.fe_container_port, protocol = "tcp" }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "fe"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "be" {
  family                   = "${var.project}-${var.env}-be"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  # cpu                      = "256"
  # memory                   = "512"
  memory                   = "128"

  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name         = "be"
    image        = var.be_image
    essential    = true
    portMappings = [{ containerPort = var.be_container_port, "hostPort": var.be_container_port, protocol = "tcp" }]

    environment = [
      for k, v in var.be_env : { name = k, value = v }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "be"
      }
    }
  }])
}

resource "aws_ecs_service" "fe" {
  name            = "${var.project}-${var.env}-fe"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.fe.arn
  desired_count   = var.fe_desired_count
  launch_type     = "EC2"

  force_new_deployment = true

  network_configuration {
    subnets         = local.private_app_subnets
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fe.arn
    container_name   = "fe"
    container_port   = var.fe_container_port
  }

  depends_on = [aws_autoscaling_group.ecs]
}

resource "aws_ecs_service" "be" {
  name            = "${var.project}-${var.env}-be"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.be.arn
  desired_count   = var.be_desired_count
  launch_type     = "EC2"

  force_new_deployment = true

  network_configuration {
    subnets         = local.private_app_subnets
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.be.arn
    container_name   = "be"
    container_port   = var.be_container_port
  }

  depends_on = [aws_autoscaling_group.ecs]
}
