resource "aws_subnet" "project_subnet" {
  vpc_id  = var.vpc_id
  for_each=var.subnet_info
  cidr_block = each.value[0]
  availability_zone = each.value[1]
  
    tags = merge(
      var.tags, {
        Name = each.value[2]
    }
  ) 
}