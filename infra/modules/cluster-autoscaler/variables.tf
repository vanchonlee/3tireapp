variable "aws_eks_cluster" {
    type = string
}

variable "provider_arn" {
    type = string
}

variable "namespace_service_accounts" {
    type = list(string)
}