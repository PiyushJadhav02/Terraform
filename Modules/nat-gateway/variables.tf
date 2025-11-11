variable "region" {
    default = "eu-north-1"
}

variable "vpc_id" {
    description = "Provides VPC Id"
    type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_name"{
    description = "Name of vpc"
    type = string
}

variable "route_table_id" {
  type = string
}