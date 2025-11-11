provider "aws" {
  region = var.region
}

resource "aws_security_group" "eks-cluster-sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc-id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.subnet_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "eks-node-sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS nodes"
  vpc_id      = var.vpc-id

  ingress {
    from_port   = 443
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.subnet_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}