output "eks_role_arn" {
  description = "ARN of the EKS IAM role created by this module"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_role_name" {
  description = "Name of the EKS IAM role created by this module"
  value       = aws_iam_role.eks_cluster_role.name
}
