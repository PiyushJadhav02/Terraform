variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "nat_gateway_id" {
  type = string
}

locals {
  subnet_id_map = { for idx, subnet_id in var.subnet_ids : "subnet-${idx}" => subnet_id }
}