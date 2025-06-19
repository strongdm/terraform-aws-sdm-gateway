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

output "ec2_instance_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.gateway_ec2.public_ip
}

output "ec2_instance_public_dns" {
  description = "EC2 instance public DNS"
  value       = aws_instance.gateway_ec2.public_dns
}

output "gateway_instance_name" {
  description = "Name of the StrongDM gateway instance"
  value       = aws_instance.gateway_ec2.tags["Name"]

}