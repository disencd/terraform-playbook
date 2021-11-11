provider "aws" {
  profile = "terraform"
//  profile = "default"
  region  = "us-west-2"
}

resource "aws_s3_bucket" "prod_tf_s3" {
  bucket = "s3-disencd-terraform-test1"
  acl    = "private"
}

resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "prod_web" {
  name        = "prod_web"
  description = "Allow standard http & https ports inbound and everything outbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "true"
  }
}

resource "aws_instance" "prod_web_ec2" {
  ami           = "ami-0d60bcb3cd15a7c5b"
  instance_type = "t2.nano"

  vpc_security_group_ids = [
    aws_security_group.prod_web.id
  ]

  tags = {
    "Terraform" : "true"
  }
}