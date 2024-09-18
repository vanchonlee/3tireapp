# **IAM**
TF manifest in this folder is to create:
- IAM role `terraform-role` - IAM role use to be assumed for infra resource provsion, created in  AWS account 
  
- IAM policy named `terraform-policy`  attached IAM role mentions above with permission to provison AWS resource in matching AWS account

- IAM user `terraform-user` - IAM user created in  AWS  account, which is also the only user can assume role `terraform-role` attached with IAM policy `terraform-user-policy`

- IAM policy `terraform-user-policy` has some custom permission to access central s3 state bucket named `toptal-phuc-phan-tf-state` , kms key used to encrypt terraform state file and dynamodb table `tf-state-lock` for locking state
  
- The AWS credential input for terraform provider was following to use AWS key pair on first terraform plan and provision all the resource above.
  
**Note**: this setup is required to run one time only
