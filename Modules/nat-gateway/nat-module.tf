# resource "aws_eip" "nat_eip" {
#   domain = "vpc"
# }

resource "aws_internet_gateway" "project_igw" {
  vpc_id = var.vpc_id
    tags = {
        Name = "${var.vpc_name}-igw"
    }
}

# resource "aws_nat_gateway" "nat-gateway" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = var.subnet_id
#     tags = {
#         Name = "${var.vpc_name}-nat-gateway"
#     }
  
# }
