data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "chon-le-tf-state"
    key     = "vpc/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = "chon-le-aws"
  }
}
