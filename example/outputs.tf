output "ec2_instance_public_ip" {
  description = "EC2 instance public IP"
  value       = module.sdm_gateway_1.ec2_instance_public_ip
}
output "sdm_gateway1_name" {
  description = "EC2 instance name"
  value       = module.sdm_gateway_1.gateway_instance_name
}
output "ec2_instance_public_ip_2" {
  description = "EC2 instance public IP"
  value       = module.sdm_gateway_2.ec2_instance_public_ip
}
output "sdm_gateway2_name" {
  description = "EC2 instance name"
  value       = module.sdm_gateway_2.gateway_instance_name
}