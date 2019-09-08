variable "access_key" {}
variable "secret_key" {}

variable "region" {
 description = "AWS region"
}

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

variable "instance_type" {
 description = "type for aws EC2 instance"
 default = "t2.micro"
}

variable "aws_instance_name" {
 description = "Name of instance"
}

variable "aws_private_key_name" {
   description = "Desired name of AWS key pair"
}

variable "aws_private_key_path" {
  description = "Private key file path"
}

variable "rds_vpc_id" {
 default = "vpc-XXXXXXXX"
 description = "Our default RDS virtual private cloud (rds_vpc)."
}

# rds database configuration
variable "db_engine" {
  description = "Name of the database engine to be used for this instance."
  default = "postgres"
}

variable "db_engine_version" {
  description = "Version number of the database engine to use."
  default = "10.6"
}

variable "db_instance_class" {
  description = "The compute and memory capacity of the instance"
  default = "db.t2.micro"
}

variable "db_parameter_group_name" {
  description = ""
  default = "default.postgres10"
}

variable "db_storage_type" {
  description = "Specifies the storage type for the DB instance."
}

variable "db_allocated_storage" {
  description = "Amount of storage to be initially allocated for the DB instance, in gigabytes."
  default = 20
}

variable "db_instance_identifier" {
  description = "Identifier name"
}

variable "db_instance_name" {
 description = "The name of the database."
}

variable "db_instance_user_name" {
 description = "The name of the master database user."
}

variable "db_instance_user_password" {
   description = "Password for the master DB instance user"
}

# ssl
variable "ssl_certifcate_path" {
   description = "ssl certificate path"
}

variable "ssl_private_key_path" {
   description = "ssl private key path"
}
