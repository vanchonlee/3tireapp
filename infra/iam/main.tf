module "tier-app" {
  source                     = "../modules/3tier-app"
  aws_eks_cluster            = data.terraform_remote_state.eks.outputs.cluster_name
  provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  namespace_service_accounts = ["prod:tier-app-api-external-sercret"]
}


module "cluster_autoscaler" {
  source                     = "../modules/cluster-autoscaler"
  aws_eks_cluster            = data.terraform_remote_state.eks.outputs.cluster_name
  provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  namespace_service_accounts = ["kube-system:cluster-autoscaler"]
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["vanchonlee/3tireapp"]
  oidc_role_attach_policies = [
    "arn:aws:iam::082168422974:policy/terraform-policy",
  ]
}
