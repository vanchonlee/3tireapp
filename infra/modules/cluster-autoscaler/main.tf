data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
    ]
  }

  statement {
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "cluster-autoscaler-policy-${var.aws_eks_cluster}"
  description = "Cluster autoscaler policy ${var.aws_eks_cluster}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "5.33.0"
  role_name = "cluster-autoscaler-${var.aws_eks_cluster}"

  role_policy_arns = {
    policy = aws_iam_policy.cluster_autoscaler_policy.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.provider_arn
      namespace_service_accounts = var.namespace_service_accounts
    }
  }
}
