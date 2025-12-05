terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "> 6.16.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc-module" {
    source = "./Modules/vpc"
    cidr_block = "11.0.0.0/16"
    vpc_name = "Project_vpc"
}

data "aws_vpc" "project_vpc" {
  filter {
    name="tag:Name"
    values = ["Project_vpc"]
  }
  depends_on = [ module.vpc-module ]
}

module "subnet-pub-module" {
  source = "./Modules/subnet"
    subnet_info = {
        a =["11.0.0.0/24", "${var.region}a", "subnet-pub1"],
        b=["11.0.1.0/24", "${var.region}b", "subnet-pub2"],
}
    vpc_id = data.aws_vpc.project_vpc.id
    depends_on = [ module.vpc-module ]
    tags = {
      "kubernetes.io/cluster/project-eks-cluster"="shared"
      "kubernetes.io/role/elb"       = "1"
    }
}

module "subnet-pvt-module" {
  source = "./Modules/subnet"
  subnet_info = {
    c=["11.0.2.0/24", "${var.region}a", "subnet-pvt1"],
    d=["11.0.3.0/24", "${var.region}b", "subnet-pvt2"]
  }

  vpc_id = data.aws_vpc.project_vpc.id
    depends_on = [ module.vpc-module ]
    tags = {
      "kubernetes.io/cluster/project-eks-cluster"="shared"
      "kubernetes.io/role/internal-elb"       = "1"
    }
}

module "Iam-role" {
    source = "./Modules/Iam"
    depends_on = [ module.vpc-module ]
}

module "security-group" {
  source = "./Modules/security-group"
  region = var.region
  vpc-id = data.aws_vpc.project_vpc.id
  subnet_ids = concat( module.subnet-pub-module.subnet_ids, module.subnet-pvt-module.subnet_ids )
  depends_on = [ module.vpc-module ]
}


# module "eks_cluster" {
#   source = "./Modules/eks"
#   eks_cluster_name = "project-eks-cluster"
#   role_arn = module.Iam-role.eks_role_arn
#   eks_node_role_arn = module.Iam-role.eks_node_role_arn
#   subnet_ids = module.subnet-pvt-module.subnet_ids    
#   security_group_ids = [module.security-group.security_group_ids]
#   depends_on = [ module.vpc-module, module.subnet-pub-module, module.subnet-pvt-module, module.Iam-role ]
# }

data "aws_route_table" "public_rt" {
    vpc_id = data.aws_vpc.project_vpc.id
    depends_on = [ module.vpc-module ]
}

data "aws_subnet" "public_subnets" {
    filter {
        name = "tag:Name"
        values = ["subnet-pub1"]
    }
    depends_on = [ module.subnet-pub-module ]
}

module "nat_gateway" {
  source = "./Modules/nat-gateway"
  subnet_id = data.aws_subnet.public_subnets.id
    route_table_id = data.aws_route_table.public_rt.id
    vpc_id = data.aws_vpc.project_vpc.id
    vpc_name = "Project_vpc"
    depends_on = [ module.subnet-pub-module ]
}