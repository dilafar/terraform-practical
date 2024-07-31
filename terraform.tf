terraform {
  backend "s3" {
    bucket = "terraform-eks-test"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }

  required_version = "~> 1.7.4"
  
}