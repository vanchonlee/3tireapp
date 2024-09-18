data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket  = "chon-le-tf-state"
    key     = "eks/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = "chon-le-aws"
  }
}
