variable "region" {
  default = "eu-north-1"
}

variable "role_arn" {
  description = "The ARN of the IAM role that provides permissions for EKS to make AWS API calls on your behalf."
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type = string
}

variable "eks_node_role_arn" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "log-types" {
  type = list(string)
}
