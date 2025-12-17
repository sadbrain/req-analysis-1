output "nat_public_ips" {
  description = "NAT instance public IPs"
  value       = module.nat.nat_public_ips
}