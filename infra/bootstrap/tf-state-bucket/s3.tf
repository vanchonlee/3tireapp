provider "aws" {
  profile = "chon-le-aws"
  region  = "ap-southeast-1"
  assume_role {
    role_arn = "arn:aws:iam::082168422974:role/terraform-role"
  }
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "chon-le-tf-state"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform_state_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "dynamodb_terraform_lock" {
  name           = "tf-state-lock"
  billing_mode   = "PROVISIONED"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_kms_key" "terraform_state_key" {
  description             = "KMS key for encrypting Terraform state"
  deletion_window_in_days = 7
}
