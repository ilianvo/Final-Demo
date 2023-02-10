output "s3_bucket_domain_name" {
  value       = join("", aws_s3_bucket.default.*.bucket_domain_name)
  description = "S3 bucket domain name"
}

output "dynamodb_table_name" {
  value = element(
    coalescelist(
      aws_dynamodb_table.with_server_side_encryption.*.name,
      [""]
    ),
    0
  )
  description = "DynamoDB table name"
}


output "terraform_backend_config" {
  value       =  local.terraform_backend_config_content
  description = "Rendered Terraform backend config file"
}
