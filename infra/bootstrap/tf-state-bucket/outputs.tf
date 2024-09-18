output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.dynamodb_terraform_lock.name
}
output "dynamodb_table_arn" {
  value = aws_dynamodb_table.dynamodb_terraform_lock.arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.terraform_state_key.arn
}
output "kms_id" {
  value = aws_kms_key.terraform_state_key.key_id
}
output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state_bucket.arn
}
