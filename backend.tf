terraform {
  backend "s3" {
    bucket         = "aws-terraform-tffile-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
