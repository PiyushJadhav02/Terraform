provider "aws" {
  region = var.region
}

resource "aws_vpc" "project_vpc" {
  cidr_block = var.cidr_block
    tags = {
        Name = var.vpc_name
    }
}