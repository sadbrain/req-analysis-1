# ============================================================================
# SQS MODULE - Message Queue
# ============================================================================

# Main SQS Queue
resource "aws_sqs_queue" "main" {
  name                       = "${var.project}-${var.env}-queue"
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  # Enable encryption at rest
  sqs_managed_sse_enabled = true

  # Dead Letter Queue configuration
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Name = "${var.project}-${var.env}-queue"
  }
}

# Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "dlq" {
  name                       = "${var.project}-${var.env}-dlq"
  message_retention_seconds  = var.dlq_message_retention_seconds
  sqs_managed_sse_enabled    = true

  tags = {
    Name = "${var.project}-${var.env}-dlq"
  }
}

# CloudWatch Alarm - DLQ has messages
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.project}-${var.env}-sqs-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "CRITICAL: Messages in SQS Dead Letter Queue"
  alarm_actions       = [var.critical_sns_topic_arn]

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }
}

# CloudWatch Alarm - Queue age of oldest message
resource "aws_cloudwatch_metric_alarm" "queue_age" {
  alarm_name          = "${var.project}-${var.env}-sqs-message-age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "600"  # 10 minutes
  alarm_description   = "BUSINESS: SQS messages not being processed (age > 10 min)"
  alarm_actions       = [var.business_sns_topic_arn]

  dimensions = {
    QueueName = aws_sqs_queue.main.name
  }
}

# SQS Queue Policy - Allow ECS task role to send/receive messages
resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.ecs_task_execution_role_arn
        }
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.main.arn
      }
    ]
  })
}
