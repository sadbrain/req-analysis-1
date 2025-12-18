# ============================================================================
# NAT INSTANCES MODULE
# ============================================================================

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_iam_role" "nat_instance_role" {
  name = "${var.project}-${var.env}-nat-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "nat_instance_ssm" {
  role       = aws_iam_role.nat_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nat_instance_profile" {
  name = "${var.project}-${var.env}-nat-instance-profile"
  role = aws_iam_role.nat_instance_role.name
}

resource "aws_instance" "nat" {
  count = length(var.azs)

  ami                         = data.aws_ami.al2023.id
  instance_type               = var.nat_instance_type
  subnet_id                   = var.public_subnets[count.index]
  vpc_security_group_ids      = [var.nat_security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.nat_instance_profile.name
  key_name                    = var.key_name != "" ? var.key_name : null
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = templatefile("${path.module}/user-data.sh", {
    vpc_cidr = var.vpc_cidr
  })

  tags = {
    Name = "${var.project}-${var.env}-nat-${count.index}"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami]
  }
}

resource "aws_route" "private_app_default" {
  count                  = length(var.azs)
  route_table_id         = var.private_app_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat[count.index].primary_network_interface_id
}
