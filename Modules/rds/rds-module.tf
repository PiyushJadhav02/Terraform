resource "aws_db_subnet_group" "rds_subnet_group" {
    name       = "project-rds-subnet-group"
    subnet_ids = var.subnet_ids

    tags = {
        Name = "project-rds-subnet-group"
    }
  
}

resource "aws_db_instance" "rds" {
    engine = var.engine
    instance_class = var.instance_class
    allocated_storage = var.allocated_storage
    identifier = "project-rds-instance"

    db_name = var.db_name
    username = var.username
    password = var.password

    vpc_security_group_ids = var.vpc_security_group_ids
    db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
    multi_az = true
}