# ============================================================================
# ECS COMPUTE MODULE (ASG + Capacity Provider)
# ============================================================================

# ECS Instance IAM Role
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.project}-${var.env}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project}-${var.env}-ecs-instance-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.project}-${var.env}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# Get latest ECS-optimized AMI
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Launch Template
resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project}-${var.env}-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.ecs_instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  vpc_security_group_ids = [var.ecs_security_group_id]

  monitoring {
    enabled = false
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    cluster_name = var.ecs_cluster_name
  }))

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ecs" {
  name                = "${var.project}-${var.env}-ecs-asg"
  vpc_zone_identifier = var.private_app_subnets

  desired_capacity = var.ecs_desired_capacity
  min_size         = var.ecs_min_size
  max_size         = var.ecs_max_size

  default_cooldown          = 150
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-ecs-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# # Capacity Provider
# resource "aws_ecs_capacity_provider" "this" {
#   name = "${var.project}-${var.env}-cp"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
#     managed_termination_protection = "DISABLED"

#     managed_scaling {
#       status                    = "ENABLED"
#       target_capacity           = 80
#       minimum_scaling_step_size = 1
#       maximum_scaling_step_size = 10
#     }
#   }

#   tags = {
#     Name = "${var.project}-${var.env}-capacity-provider"
#   }
# }

# resource "aws_ecs_cluster_capacity_providers" "this" {
#   cluster_name = var.ecs_cluster_name

#   capacity_providers = [aws_ecs_capacity_provider.this.name]

#   default_capacity_provider_strategy {
#     capacity_provider = aws_ecs_capacity_provider.this.name
#     weight            = 1
#     base              = 0
#   }
# }
