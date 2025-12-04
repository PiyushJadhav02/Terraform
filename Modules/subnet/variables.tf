variable "subnet_info" {
  type = map(list(string))
  description = "The information for the subnets"
}

variable "region" {
  default = "eu-north-1"
}

variable "vpc_id" {
  description = "Provides VPC Id"
  type = string
}

variable "tags" {
  type = map(string)
}