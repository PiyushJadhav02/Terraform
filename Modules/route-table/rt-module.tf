resource "aws_route_table" "pvt-route-table" {
  vpc_id = var.vpc_id
    tags = {
        Name = "pvt-route-table"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = var.nat_gateway_id
    }
}

resource "aws_route_table_association" "nat_subnet_association" {
  for_each = local.subnet_id_map
  subnet_id      = each.value
  route_table_id = aws_route_table.pvt-route-table.id
}

