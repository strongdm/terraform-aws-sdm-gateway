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

output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.bucket.id
}