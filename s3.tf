resource "aws_s3_bucket" "main" {
  bucket = "terra-bucket-3"
  acl    = "private"
}