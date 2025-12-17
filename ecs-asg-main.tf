data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project}-${var.env}-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.ecs_instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.ecs.id]

  # Monitoring disabled to avoid additional costs
  monitoring {
    enabled = false
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -xe
    exec > >(tee /var/log/user-data.log)
    exec 2>&1

    echo "Configuring ECS cluster membership..."
    echo "ECS_CLUSTER=${aws_ecs_cluster.this.name}" >> /etc/ecs/ecs.config
    echo "ECS_ENABLE_TASK_IAM_ROLE=true" >> /etc/ecs/ecs.config
    echo "ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true" >> /etc/ecs/ecs.config
    
    # Enable awsvpc network mode support
    echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"awslogs\"]" >> /etc/ecs/ecs.config

    # # Ensure SSM Agent is running
    # systemctl enable amazon-ssm-agent
    # systemctl start amazon-ssm-agent

    # # Enable Docker
    # systemctl enable docker
    # systemctl start docker

    # Restart ECS agent after configuration changes
    # systemctl restart ecs
    # systemctl enable ecs

    # Log initialization completion
    echo "=== ECS instance initialization completed at $(date) ===" >> /var/log/ecs-init.log
    echo "SSM Agent Status: $(systemctl is-active amazon-ssm-agent)" >> /var/log/ecs-init.log
    echo "ECS Agent Status: $(systemctl is-active ecs)" >> /var/log/ecs-init.log
  EOF
  )
}

resource "aws_autoscaling_group" "ecs" {
  name                = "${var.project}-${var.env}-ecs-asg-v2"
  vpc_zone_identifier = local.private_app_subnets

  desired_capacity = var.ecs_desired_capacity
  min_size         = var.ecs_min_size
  max_size         = var.ecs_max_size

  default_cooldown = 150
  wait_for_capacity_timeout = "0"

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
