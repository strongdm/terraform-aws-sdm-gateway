output "vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.vpc.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = data.aws_subnet.subnet.id
}

output "default_tags" {
  description = "Standard tags applied to all resources"
  value       = local.default_tags
}

output "sdm_account_ids" {
  description = "StrongDM account IDs"
  value       = data.sdm_account.api-key-queries.ids
}

output "private_key" {
  description = "Private key"
  value       = tls_private_key.sdm_gw_key_pair.private_key_pem
  sensitive   = true
}

output "ec2_instance_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.gateway_ec2.public_ip
}