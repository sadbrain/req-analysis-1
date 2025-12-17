# resource "aws_ecs_capacity_provider" "asg" {
#   name = "${var.project}-${var.env}-cp"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn = aws_autoscaling_group.ecs.arn

#     managed_scaling {
#       status                    = "ENABLED"
#       target_capacity           = 0
#       # target_capacity           = 100
#       minimum_scaling_step_size = 1
#       maximum_scaling_step_size = 2
#     }

#     managed_termination_protection = "DISABLED"
#   }
# }

# resource "aws_ecs_cluster_capacity_providers" "this" {
#   cluster_name = aws_ecs_cluster.this.name

#   capacity_providers = [aws_ecs_capacity_provider.asg.name]

#   default_capacity_provider_strategy {
#     capacity_provider = aws_ecs_capacity_provider.asg.name
#     weight            = 1
#   }
# }
