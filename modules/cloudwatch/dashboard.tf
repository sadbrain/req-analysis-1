# ============================================================================
# CLOUDWATCH DASHBOARD - SIMPLIFIED (Single Dashboard)
# ============================================================================
# Cost: $3/dashboard/month x 1 = $3/month
# Combines essential metrics from ALB, ECS, RDS in one view
# ============================================================================

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project}-${var.env}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: ALB Performance
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "Average", label = "Response Time (avg)" }],
            ["...", { stat = "p95", label = "Response Time (p95)" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { stat = "Sum", label = "5XX Errors", yAxis = "right" }],
            [".", "RequestCount", ".", ".", { stat = "Sum", label = "Requests", yAxis = "right" }]
          ]
          period = 300
          region = var.aws_region
          title  = "ALB Performance & Errors"
          yAxis = {
            left  = { label = "Response Time (s)" }
            right = { label = "Count" }
          }
        }
      },
      # Row 1: ALB Health
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.alb_arn_suffix, { stat = "Average", label = "Healthy Hosts" }],
            [".", "UnHealthyHostCount", ".", ".", { stat = "Average", label = "Unhealthy Hosts" }]
          ]
          period = 60
          region = var.aws_region
          title  = "ALB Target Health"
          yAxis = {
            left = { label = "Count", min = 0 }
          }
        }
      },
      # Row 2: ECS Cluster Resources
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", var.ecs_cluster_name, { stat = "Average", label = "Running Tasks" }],
            ["AWS/ECS", "CPUUtilization", ".", ".", { stat = "Average", label = "Cluster CPU %" }],
            [".", "MemoryUtilization", ".", ".", { stat = "Average", label = "Cluster Memory %" }]
          ]
          period = 300
          region = var.aws_region
          title  = "ECS Cluster Resources"
          yAxis = {
            left = { label = "Percent / Count" }
          }
        }
      },
      # Row 2: RDS Performance
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", var.rds_cluster_id, { stat = "Average", label = "CPU %" }],
            [".", "DatabaseConnections", ".", ".", { stat = "Average", label = "Connections", yAxis = "right" }],
            [".", "FreeableMemory", ".", ".", { stat = "Average", label = "Free Memory (bytes)", yAxis = "right" }]
          ]
          period = 300
          region = var.aws_region
          title  = "RDS Performance"
          yAxis = {
            left  = { label = "CPU %", min = 0, max = 100 }
            right = { label = "Connections / Memory" }
          }
        }
      }
    ]
  })
}
