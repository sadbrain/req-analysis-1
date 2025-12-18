# ============================================================================
# MAINTENANCE MODULE
# ============================================================================

# Parameter Store to toggle maintenance mode (ON/OFF)
resource "aws_ssm_parameter" "maintenance_mode" {
  name        = "/${var.project}/${var.env}/maintenance-mode"
  description = "Maintenance mode toggle (ON or OFF)"
  type        = "String"
  value       = "OFF"

  tags = {
    Name = "${var.project}-${var.env}-maintenance-mode"
  }

  lifecycle {
    ignore_changes = [value] # Allow manual changes via console/CLI
  }
}

# Lambda function to toggle maintenance mode on ALB
resource "aws_lambda_function" "maintenance_toggle" {
  filename      = "${path.module}/lambda/maintenance_toggle.zip"
  function_name = "${var.project}-${var.env}-maintenance-toggle"
  role          = aws_iam_role.lambda_maintenance.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 30

  environment {
    variables = {
      LISTENER_ARN           = var.alb_listener_arn
      MAINTENANCE_RULE_PRIORITY = "10"
      PARAMETER_NAME         = aws_ssm_parameter.maintenance_mode.name
    }
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_maintenance" {
  name = "${var.project}-${var.env}-lambda-maintenance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Lambda policy
resource "aws_iam_role_policy" "lambda_maintenance" {
  name = "${var.project}-${var.env}-lambda-maintenance"
  role = aws_iam_role.lambda_maintenance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:ModifyRule"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:PutParameter"
        ]
        Resource = aws_ssm_parameter.maintenance_mode.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# EventBridge rule to trigger Lambda (manual invoke or scheduled)
resource "aws_cloudwatch_event_rule" "maintenance_toggle" {
  name                = "${var.project}-${var.env}-maintenance-toggle"
  description         = "Manual trigger for maintenance mode toggle"
  event_pattern       = jsonencode({
    source      = ["custom.maintenance"]
    detail-type = ["Maintenance Toggle"]
  })
}

resource "aws_cloudwatch_event_target" "maintenance_toggle" {
  rule      = aws_cloudwatch_event_rule.maintenance_toggle.name
  target_id = "MaintenanceToggleLambda"
  arn       = aws_lambda_function.maintenance_toggle.arn
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.maintenance_toggle.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.maintenance_toggle.arn
}

# EventBridge Schedule: Trigger maintenance ON every 5th of month at 7:30 PM
resource "aws_cloudwatch_event_rule" "maintenance_schedule" {
  name                = "${var.project}-${var.env}-maintenance-schedule"
  description         = "Auto-enable maintenance mode on 5th of each month at 7:30 PM"
  schedule_expression = "cron(30 19 5 * ? *)"
}

resource "aws_cloudwatch_event_target" "maintenance_schedule" {
  rule      = aws_cloudwatch_event_rule.maintenance_schedule.name
  target_id = "MaintenanceScheduleLambda"
  arn       = aws_lambda_function.maintenance_toggle.arn
  input     = jsonencode({
    detail = {
      action = "ON"
    }
  })
}

resource "aws_lambda_permission" "eventbridge_schedule" {
  statement_id  = "AllowEventBridgeScheduleInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.maintenance_toggle.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.maintenance_schedule.arn
}
