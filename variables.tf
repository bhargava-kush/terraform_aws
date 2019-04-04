variable "access_key" {}
variable "secret_key" {}

variable "amis" {
  type = "map"
}

variable "environment" {
  type    = "string"
  default = "test"
}

variable "s3_bucket_prefix" {
  default     = "terra-bucket-3"
  description = "Prefix of s3 bucket"
  type        = "string"
}

variable "s3_region" {
  type = "string"
}

locals {
  s3_tags = {
    created_by  = "terraform"
    environment = "${var.environment}"
  }
}
