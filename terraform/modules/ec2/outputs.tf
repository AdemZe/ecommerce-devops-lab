output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "Public IPs (empty if in private subnet — use private IPs via bastion)"
  value       = aws_instance.web[*].public_ip
}

output "instance_private_ips" {
  description = "Private IPs used by Ansible via NAT / bastion"
  value       = aws_instance.web[*].private_ip
}
