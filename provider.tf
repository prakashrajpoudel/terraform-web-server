provider "aws" {
    region = "${var.aws_region}"
    version = "~> 2.68.0"
}

terraform {
  backend "s3" {
    bucket = "ppoudel-aws-terraform-backend-state"
    key    = "sample/us-east-1.tfstate"
    region = "us-east-1"
  }
}
