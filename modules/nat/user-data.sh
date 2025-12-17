#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting NAT instance configuration..."

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# Relax rp_filter for NAT forwarding
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.conf.default.rp_filter=0
echo "net.ipv4.conf.all.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 0" >> /etc/sysctl.conf

# Get the primary network interface
IFACE="$(ip -o -4 route show to default | awk '{print $5}' | head -n1)"
echo "Primary interface: $IFACE"

# Configure iptables for NAT
iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE

# Ensure forwarding is allowed
iptables -P FORWARD ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s ${vpc_cidr} -j ACCEPT

# Persist rules if possible
if command -v yum >/dev/null 2>&1; then
  yum install -y iptables-services || true
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y iptables-services || true
fi

systemctl enable iptables 2>/dev/null || true
service iptables save 2>/dev/null || true

# Ensure SSM Agent is running
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "NAT instance configuration completed successfully"
