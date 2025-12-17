# ============================================================================
# ECS CLUSTER MODULE
# ============================================================================

resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.env}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"  # Set to "enabled" if needed (may incur costs)
  }

  tags = {
    Name = "${var.project}-${var.env}-cluster"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project}-${var.env}"
  retention_in_days = 7

  tags = {
    Name = "${var.project}-${var.env}-ecs-logs"
  }
}

# Task Execution Role (for pulling images, writing logs)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project}-${var.env}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project}-${var.env}-ecs-task-exec-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
