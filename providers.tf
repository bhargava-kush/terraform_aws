provider "aws" {
  region = "${var.s3_region}"
  shared_credentials_file = "~/.aws/credentials"
}

terraform {
  backend "s3" {

    bucket = "ftl-bucket-terraform-test-ap-south-1"
    key = "test/terraform"
    region = "ap-south-1"
    encrypt = "true"
  }
}