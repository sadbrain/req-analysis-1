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
  iam_instance_profile         = aws_iam_instance_profile.nat_instance_profile.name
  key_name                    = var.key_name != "" ? var.key_name : null 
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = <<-EOF
  #!/bin/bash
  set -e
  exec > >(tee /var/log/user-data.log)
  exec 2>&1

  echo "Starting NAT instance configuration..."

  # Enable IP forwarding
  sysctl -w net.ipv4.ip_forward=1
  echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

  # NAT instances often need rp_filter relaxed to avoid dropping asymmetric/routed traffic
  sysctl -w net.ipv4.conf.all.rp_filter=0
  sysctl -w net.ipv4.conf.default.rp_filter=0
  echo "net.ipv4.conf.all.rp_filter = 0" >> /etc/sysctl.conf
  echo "net.ipv4.conf.default.rp_filter = 0" >> /etc/sysctl.conf

  # Get the primary network interface
  IFACE="$(ip -o -4 route show to default | awk '{print $5}' | head -n1)"
  echo "Primary interface: $IFACE"

  # Configure iptables for NAT
  iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE

  # Ensure forwarding is allowed (some distros default FORWARD policy to DROP)
  iptables -P FORWARD ACCEPT
  iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  iptables -A FORWARD -s ${var.vpc_cidr} -j ACCEPT
  
  # Install iptables-services to persist rules
  if command -v yum >/dev/null 2>&1; then
    yum install -y iptables-services || true
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y iptables-services || true
  fi

  # Persist rules if the service exists (AL2023 may not have iptables service)
  systemctl enable iptables 2>/dev/null || true
  service iptables save 2>/dev/null || true

  # Ensure SSM Agent is running
  systemctl enable amazon-ssm-agent
  systemctl start amazon-ssm-agent

  echo "NAT instance configuration completed successfully"
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
