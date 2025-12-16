data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project}-${var.env}-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.ecs_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.ecs.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -xe

    echo "ECS_CLUSTER=${aws_ecs_cluster.this.name}" > /etc/ecs/ecs.config

    systemctl enable --now ecs
    systemctl restart ecs
  EOF
  )
}

resource "aws_autoscaling_group" "ecs" {
  name                = "${var.project}-${var.env}-ecs-asg"
  vpc_zone_identifier = local.private_app_subnets

  desired_capacity = var.ecs_desired_capacity
  min_size         = var.ecs_min_size
  max_size         = var.ecs_max_size

  default_cooldown = 150

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  availability_zone_distribution {
    capacity_distribution_strategy = "balanced-only"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-ecs-node"
    propagate_at_launch = true
  }
}
