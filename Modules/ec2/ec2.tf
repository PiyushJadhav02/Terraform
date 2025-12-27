resource "aws_instance" "ec2-instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    user_data = file("${path.module}/script.sh")
        key_name = var.key_name
        associate_public_ip_address = var.associate_public_ip_address
        security_groups = var.security_group_ids
}