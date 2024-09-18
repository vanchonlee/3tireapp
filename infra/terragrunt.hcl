remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "chon-le-tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tf-state-lock"
    profile        = "chon-le-aws"
    encrypt        = true
    kms_key_id     = "351e18ca-89f6-456f-9045-3c92ab9"
  }
}

# stage/terragrunt.hcl
generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider aws {
  region  = var.region
  profile = "chon-le-aws"

 
}


terraform {
  required_version = ">=1.1.9"
  required_providers {

    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }

    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 0.1"
    }

  }
}
EOF
}
