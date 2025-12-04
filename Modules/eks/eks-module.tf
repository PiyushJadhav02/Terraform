resource "aws_eks_cluster" "project-cluster" {
    name=var.eks_cluster_name
    role_arn = var.role_arn
    version = "1.33"
    vpc_config {
        subnet_ids = var.subnet_ids
    }
    
}

resource "aws_eks_node_group" "eks_node_group" {
    cluster_name=aws_eks_cluster.project-cluster.name
    node_group_name="project-eks-node-group"
    node_role_arn=var.eks_node_role_arn
    subnet_ids=var.subnet_ids
    instance_types=["t3.medium"]
    scaling_config {
      desired_size = 2
      max_size = 3
      min_size = 1
    }
}