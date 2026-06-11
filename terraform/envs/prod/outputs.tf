# Root outputs consumed by GitHub Actions and external tooling

output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = module.ec2.instance_ids
}

output "instance_public_ips" {
  description = "List of EC2 public IPs"
  value       = module.ec2.instance_public_ips
}

output "instance_private_ips" {
  description = "List of EC2 private IPs"
  value       = module.ec2.instance_private_ips
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = module.alb.alb_dns_name
}
