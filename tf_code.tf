provider "aws" {
  profile = "terraform"
  region = "us-west-2"
}

resource "aws_s3_bucket" "tf_s3" {
  bucket = "s3_disencd"
  acl = "private"
}