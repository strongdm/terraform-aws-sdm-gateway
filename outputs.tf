output "vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.vpc.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = data.aws_subnet.subnet.id
}

output "default_tags" {
  description = "Standard tags applied to all resources (includes Name, ManagedBy, Application)"
  value       = local.default_tags
}
