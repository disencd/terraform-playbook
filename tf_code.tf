provider "aws" {
  profile = "terraform"
  region = "us-west-2"
}

resource "aws_s3_bucket" "tf_s3" {
  bucket = "s3-disencd"
  acl = "private"
}