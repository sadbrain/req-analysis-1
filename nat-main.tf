data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "nat" {
  count = 2

  ami                         = data.aws_ami.al2023.id
  instance_type               = var.nat_instance_type
  subnet_id                   = local.public_subnets[count.index]
  vpc_security_group_ids      = [aws_security_group.nat.id]
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = <<-EOF
  #!/bin/bash
  set -e

  sysctl -w net.ipv4.ip_forward=1
  echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

  IFACE="$(ip -o -4 route show to default | awk '{print $5}' | head -n1)"
  iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE
  EOF

  tags = {
    Name = "${var.project}-${var.env}-nat-${count.index}"
  }
}

# resource "aws_route_table" "private_app" {
#   count  = 2
#   vpc_id = module.vpc.vpc_id

#   tags = {
#     Name = "${var.project}-${var.env}-rt-private-app-${count.index}"
#   }
# }

resource "aws_route" "private_app_default" {
  count                  = length(var.azs)
  route_table_id         = module.vpc.private_app_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat[count.index].primary_network_interface_id
}

# resource "aws_route_table_association" "private_app" {
#   count          = 2
#   subnet_id      = local.private_app_subnets[count.index]
#   route_table_id = aws_route_table.private_app[count.index].id
# }

# resource "aws_route" "private_default_via_nat" {
#   count                  = 2
#   route_table_id         = module.vpc.private_route_table_id
#   destination_cidr_block = "0.0.0.0/0"
#   network_interface_id   = aws_instance.nat[count.index].primary_network_interface_id
# }
