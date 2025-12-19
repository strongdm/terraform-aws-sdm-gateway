#------------------------------------------------------------------------------
# Gateway 1 Outputs
#------------------------------------------------------------------------------
output "gateway_1_name" {
  description = "Gateway 1 instance name"
  value       = module.sdm_gateway_1.gateway_instance_name
}

output "gateway_1_public_ip" {
  description = "Gateway 1 public IP"
  value       = module.sdm_gateway_1.ec2_instance_public_ip
}

output "gateway_1_public_dns" {
  description = "Gateway 1 public DNS"
  value       = module.sdm_gateway_1.ec2_instance_public_dns
}

#------------------------------------------------------------------------------
# Gateway 2 Outputs
#------------------------------------------------------------------------------
output "gateway_2_name" {
  description = "Gateway 2 instance name"
  value       = module.sdm_gateway_2.gateway_instance_name
}

output "gateway_2_public_ip" {
  description = "Gateway 2 public IP"
  value       = module.sdm_gateway_2.ec2_instance_public_ip
}

output "gateway_2_public_dns" {
  description = "Gateway 2 public DNS"
  value       = module.sdm_gateway_2.ec2_instance_public_dns
}

#------------------------------------------------------------------------------
# Gateway 3 Outputs
#------------------------------------------------------------------------------
output "gateway_3_name" {
  description = "Gateway 3 instance name"
  value       = module.sdm_gateway_3.gateway_instance_name
}

output "gateway_3_public_ip" {
  description = "Gateway 3 public IP"
  value       = module.sdm_gateway_3.ec2_instance_public_ip
}

output "gateway_3_public_dns" {
  description = "Gateway 3 public DNS"
  value       = module.sdm_gateway_3.ec2_instance_public_dns
}

#------------------------------------------------------------------------------
# Private Gateway Outputs
#------------------------------------------------------------------------------
output "gateway_private_name" {
  description = "Private gateway instance name"
  value       = module.sdm_gateway_private.gateway_instance_name
}

output "gateway_private_public_ip" {
  description = "Private gateway public IP (will be empty)"
  value       = module.sdm_gateway_private.ec2_instance_public_ip
}

#------------------------------------------------------------------------------
# VPC Outputs
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.nat.public_ip
}
