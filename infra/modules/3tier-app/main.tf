data "aws_iam_policy_document" "external-secret" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:ssm:ap-southeast-1:082168422974:parameter/tier-app-password",
      "arn:aws:ssm:ap-southeast-1:082168422974:parameter/tier-app-username",
      "arn:aws:ssm:ap-southeast-1:082168422974:parameter/datadog-api",
    ]
    actions = [
      "ssm:GetParameter",
    ]
  }
}

resource "aws_iam_policy" "external_secret_policy" {
  name        = "external-secret-policy"
  description = "Policy to access external secret"
  policy      = data.aws_iam_policy_document.external-secret.json
}

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "5.33.0"
  role_name = "tier-app-access-ssm-${var.aws_eks_cluster}"

  role_policy_arns = {
    policy = aws_iam_policy.external_secret_policy.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.provider_arn
      namespace_service_accounts = var.namespace_service_accounts
    }
  }
}
