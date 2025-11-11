variable "region" {
    default = "eu-north-1"
}

variable "vpc-id"  {
    description = "Provides VPC Id"
    type = string
}

variable "subnet_ids" {
    description = "List of subnet ids"
    type = list(string)
}