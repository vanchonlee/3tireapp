# Retrieve remote state of tf-state-bucket
data "terraform_remote_state" "s3_tf_bucket_shared" {
  backend = "s3"
  config = {
    bucket  = "chon-le-tf-state"
    key     = "bootstrap/tf-state-bucket.tfstate"
    region  = "ap-southeast-1"
    profile = "chon-le-aws"
  }
}
