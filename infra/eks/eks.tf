locals {
  name   = "3tier-app"
  region = var.region
  tags = {
    Terraform = "true"
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.11.0"

  cluster_name    = local.name
  cluster_version = "1.29"

  cluster_endpoint_public_access = true
  create_cloudwatch_log_group    = false

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = [data.terraform_remote_state.vpc.outputs.private_subnets[0], data.terraform_remote_state.vpc.outputs.private_subnets[1], data.terraform_remote_state.vpc.outputs.private_subnets[2]]
  control_plane_subnet_ids = []

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  self_managed_node_group_defaults = {
    # enable discovery of autoscaling groups by cluster-autoscaler
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${local.name}" : "owned",
    }
  }
  self_managed_node_groups = {
    workload = {
      name          = "workload-self-mng"
      instance_type = "t3.small"
      min_size      = 1
      max_size      = 3
      desired_size  = 1

      launch_template_name            = "workload-mng-lt"
      launch_template_use_name_prefix = true
      launch_template_description     = "Self managed node group worklods launch template"

      ebs_optimized     = true
      enable_monitoring = false

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = module.ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
      }
    }
    additional-workload = {
      name          = "additional-workload-self-mng"
      instance_type = "t3.medium"
      min_size      = 2
      max_size      = 4
      desired_size  = 2

      launch_template_name            = "additional-workload-mng-lt"
      launch_template_use_name_prefix = true
      launch_template_description     = "Self managed node group additional workloads launch template"

      ebs_optimized     = true
      enable_monitoring = false

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = module.ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
      }
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 2.0"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${local.name}/ebs"]

  tags = local.tags
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 2.1"

  aliases               = ["eks/${local.name}"]
  description           = "${local.name} cluster encryption key"
  enable_default_policy = true
  key_owners            = [data.aws_caller_identity.current.arn]

  tags = local.tags
}
