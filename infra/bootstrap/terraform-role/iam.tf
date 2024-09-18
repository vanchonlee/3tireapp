
data "aws_caller_identity" "dev" {

}

# Terraform user on AWS account
resource "aws_iam_user" "terraform_user" {
  name = "terraform-user"

}

# Policy to allow Terraform user to assume Terraform role
resource "aws_iam_policy" "terraform_user_policy" {
  name   = "terraform-user-policy"
  policy = data.aws_iam_policy_document.terraform_user_policy.json

}

data "aws_iam_policy_document" "terraform_user_policy" {
  # Allow Terraform user to assume role Terraform
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [aws_iam_role.terraform.arn,
    ]

    effect = "Allow"
  }
  # Policy allow to access s3 tf state bucket 
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      data.terraform_remote_state.s3_tf_bucket_shared.outputs.s3_bucket_arn,
      "${data.terraform_remote_state.s3_tf_bucket_shared.outputs.s3_bucket_arn}/*",
    ]
    effect = "Allow"
  }
  # Polilcy allow to access dynamo table for terraform locking management
  statement {
    actions   = ["dynamodb:*", ]
    resources = [data.terraform_remote_state.s3_tf_bucket_shared.outputs.dynamodb_table_arn, ]
    effect    = "Allow"
  }

  # Policy allow access kms used to encrypt/decrypt state 
  statement {
    actions   = ["kms:*", ]
    resources = [data.terraform_remote_state.s3_tf_bucket_shared.outputs.kms_key_arn, ]
    effect    = "Allow"
  }

}

resource "aws_iam_user_policy_attachment" "terraform_user_policy_policy_attachment" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = aws_iam_policy.terraform_user_policy.arn

}

# Policy allow terraform user to assume terrafrom role
data "aws_iam_policy_document" "terraform_trust" {

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_user.terraform_user.arn,
        "arn:aws:iam::082168422974:user/github-action",
      ]
    }
    effect = "Allow"
  }

}
# Terraform role in AWS account

resource "aws_iam_role" "terraform" {
  name               = "terraform-role"
  assume_role_policy = data.aws_iam_policy_document.terraform_trust.json
  tags = {
    Managed_By = "Terraform"
  }
}

# IAM Policy Document


data "aws_iam_policy_document" "terraform_policy" {
  statement {
    actions = [
      "iam:*",
      "ec2:*",
      "autoscaling:*",
      "s3:*",
      "elasticfilesystem:*",
      "eks:*",
      "ecr:*",
      "ecr:GetAuthorizationToken",
      "ecr-public:*",
      "rds:*",
      "resource-groups:*",
      "tag:*",
      "logs:*",
      "application-autoscaling:*",
      "cloudwatch:*",
      "kms:*",
      "dynamodb:*",
      "route53:*",
      "ecs:*",
      "elasticloadbalancing:*",
      "ssm:*",
      "acm:*",
      "lambda:*",
      "cognito-idp:*",
      "msk:*"
    ]
    resources = ["*"]
  }

}
resource "aws_iam_policy" "terraform_policy" {
  name   = "terraform-policy"
  policy = data.aws_iam_policy_document.terraform_policy.json
}



# Assign policy to role terraform
resource "aws_iam_policy_attachment" "terraform_policy_attachment" {
  name       = "terraform-policy-attachement"
  roles      = [aws_iam_role.terraform.name]
  policy_arn = aws_iam_policy.terraform_policy.arn
}
