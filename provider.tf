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
    b=["11.0.1.0/24", "${var.region}b", "subnet-pub2"]
  }
  vpc_id = data.aws_vpc.project_vpc.id
  depends_on = [ module.vpc-module ]
  tags = {
    "kubernetes.io/cluster/project-eks-cluster"="shared"
    "kubernetes.io/role/elb"       = "1"
  }
}

# module "subnet-pvt-module" {
#   source = "./Modules/subnet"
#   subnet_info = {
#     c=["11.0.2.0/24", "${var.region}a", "subnet-pvt1"],
#     d=["11.0.3.0/24", "${var.region}b", "subnet-pvt2"],
#     e=["11.0.4.0/24", "${var.region}a", "subnet-pvt3"],
#     f=["11.0.5.0/24", "${var.region}b", "subnet-pvt4"]
#   }

#   vpc_id = data.aws_vpc.project_vpc.id
#     depends_on = [ module.vpc-module ]
#     tags = {
#       "kubernetes.io/cluster/project-eks-cluster"="shared"
#       "kubernetes.io/role/internal-elb"       = "1"
#     }
# }

# module "Iam-role" {
#     source = "./Modules/Iam"
#     depends_on = [ module.vpc-module ]
# }

module "security-group" {
  source = "./Modules/security-group"
  region = var.region
  vpc-id = data.aws_vpc.project_vpc.id
  subnet_ids = concat(module.subnet-pvt-module.subnet_CIDR_block, module.subnet-pub-module.subnet_CIDR_block)
  depends_on = [ module.vpc-module ]
}


# module "eks_cluster" {
#   source = "./Modules/eks"
#   eks_cluster_name = "project-eks-cluster"
#   role_arn = module.Iam-role.eks_role_arn
#   eks_node_role_arn = module.Iam-role.eks_node_role_arn
#   subnet_ids = module.subnet-pvt-module.subnet_ids    
#   security_group_ids = [module.security-group.security_group_ids]
#   log-types = ["api","scheduler","controllerManager","authenticator"]
#   depends_on = [ module.vpc-module, module.subnet-pub-module, module.subnet-pvt-module, module.Iam-role ]
# }


# data "aws_subnet" "public_subnets" {
#     filter {
#         name = "tag:Name"
#         values = ["subnet-pub1"]
#     }
#     depends_on = [ module.subnet-pub-module ]
# }

module "nat_gateway" {
  source = "./Modules/nat-gateway"
    vpc_id = data.aws_vpc.project_vpc.id
    vpc_name = "Project_vpc"
    depends_on = [ module.subnet-pub-module ]
}

# module "pvt-route-table" {
#   source = "./Modules/route-table"
#   vpc_id = data.aws_vpc.project_vpc.id
#   nat_gateway_id = module.nat_gateway.nat-gateway-id
#   subnet_ids = module.subnet-pvt-module.subnet_ids
#   igw-id = module.nat_gateway.igw-id
#   default-route-table-id = data.aws_vpc.project_vpc.main_route_table_id
#   depends_on = [ module.nat_gateway, module.subnet-pvt-module ]
# }
data "aws_key_pair" "existing_key"{
  key_name = "ubuntu"
}

module "ec2-instance" {
  source = "./Modules/ec2"
  instance_type = "t3.micro"
  ami_id = "ami-0fa91bc90632c73c9"
  subnet_id = module.subnet-pub-module.subnet_ids[0]
  key_name = data.aws_key_pair.existing_key.key_name
  depends_on = [ module.subnet-pub-module ]
  associate_public_ip_address = true
  security_group_ids = [module.security-group.security_group_ids]
}