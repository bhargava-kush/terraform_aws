# The main terraform file
# STEP 1: Create an aws_db_instance rds database
# STEP 2: Create an aws_db_instance rds security group
# STEP 3: Map database and rds security group with internal terraform dependancy
# STEP 4: Create an aws_instance ec2 security group
# STEP 5: Specify the aws_ami (The machine required ubuntu or windows etc)
# STEP 6: Create an aws_instance with the specified aws_ami
# STEP 7: Create an external dependency of aws_instance with aws_db_instance rds

# STEP 1
resource "aws_db_instance" "aws-db-ref" {
 allocated_storage        = "${var.db_allocated_storage}" # gigabytes
 engine                   = "${var.db_engine}"
 engine_version           = "${var.db_engine_version}"
 identifier               = "${var.db_instance_identifier}"
 instance_class           = "${var.db_instance_class}"
 name                     = "${var.db_instance_name}"
 parameter_group_name     = "${var.db_parameter_group_name}" # if you have tuned it
 password                 = "${var.db_instance_user_password}"
 storage_type             = "${var.db_storage_type}"
 username                 = "${var.db_instance_user_name}"
 vpc_security_group_ids   = ["${aws_security_group.aws_db_instance_sg.id}"] # STEP 3
 multi_az                 = false
 port                     = 5432
 publicly_accessible      = true
 skip_final_snapshot      = true
 backup_retention_period  = 7   # in days

}


# STEP 2
resource "aws_security_group" "aws_db_instance_sg" {
 name = "aws_db_instance_sg"

 description = "RDS postgres servers (terraform-managed)"
 vpc_id = "${var.rds_vpc_id}"

 # Only postgres in
 ingress {
   from_port = 5432
   to_port = 5432
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 # Allow all outbound traffic.
 egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


# STEP 4
resource "aws_security_group" "aws_instance_sg" {
 name = "aws_instance_sg"

 description = "AWS EC2 servers (terraform-managed)"

 ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
//Allow traffic on port 443 (HTTPS)
 ingress {
   from_port = 443
   to_port = 443
   protocol = "tcp"
   cidr_blocks = [
     "0.0.0.0/0"
   ]
 }
 tags {
   "Environment" = "${var.environment}"
 }
}

# STEP 5
data "aws_ami" "ubuntu" {
 most_recent = true

 filter {
   name = "name"
   values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]

 }

 filter {
   name = "virtualization-type"
   values = ["hvm"]
 }

  owners = [""] # Canonical
}

# Creating s3 bucket
resource "aws_s3_bucket" "aws-s3-bucket-ref" {
  region = "${var.region}"
  bucket = "${var.s3_bucket_prefix}-${var.s3_region}"
  acl = "public-read-write"
  force_destroy = true
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicReadGetObject",
    "Effect":"Allow",
    "Principal": "*",
    "Action":"s3:GetObject",
    "Resource":[
      "arn:aws:s3:::${var.s3_bucket_prefix}-${var.s3_region}",
      "arn:aws:s3:::${var.s3_bucket_prefix}-${var.s3_region}/*"
    ]
  }]
}
POLICY
}


# STEP 6
resource "aws_instance" "aws-instance-ref" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  # STEP 8
  provisioner "file" {
    source = "${var.ssl_certifcate_path}"
    destination = ""
  }

  provisioner "file" {
    source = "${var.ssl_private_key_path}"
    destination = ""
  }

  provisioner "remote-exec" {
   inline = [
   "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
   "sudo apt-get -y update;",
   ]
  }
 connection {
 # The default username for our AMI
 user = "ubuntu"
 type = "ssh"
 host = "${aws_instance.aws-instance-ref.public_ip}"
 private_key = "${file(var.aws_private_key_path)}"
 agent = false
 }

  associate_public_ip_address=true

  # STEP 7
  depends_on = ["aws_db_instance.aws-db-ref",]

  security_groups = ["${aws_security_group.aws_instance_sg.name}"]

  # The name of our SSH keypair
  key_name = "${var.aws_private_key_name}"

 tags {
   Name = "${var.aws_instance_name}"
   }

}
