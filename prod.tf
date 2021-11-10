provider "aws" {
  profile = "terraform"
  region = "us-west-2"
}

resource "aws_s3_bucket" "prod_tf_s3" {
  bucket = "s3-disencd-prod"
  acl = "private"
}

resource "aws_default_vpc" "default" {

}