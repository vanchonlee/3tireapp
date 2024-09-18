

output "terrafom_role" {
  value = aws_iam_role.terraform.arn
}

output "terraform_user" {
  value = aws_iam_user.terraform_user.arn
}
output "terraform_user_id" {
  value = aws_iam_user.terraform_user.id
}
