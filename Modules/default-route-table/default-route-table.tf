resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = var.default_route_table_id
  
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  tags = {
    name = "default-route-table"
  }
}