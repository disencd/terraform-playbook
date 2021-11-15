provider "aws" {
  profile = "terraform"
  //  profile = "default"
  region = "us-west-2"
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "prod_tf_s3" {
  bucket = "s3-disencd-terraform-test1"
  acl    = "private"

  policy = jsonencode(
    {
      Id: "Policy1636986475363",
      Version: "2012-10-17",
      Statement: [
        {
          Sid: "Stmt1636986466617",
          Action: [
            "s3:PutObject"
          ],
          Effect: "Allow",
          Resource: "arn:aws:s3:::s3-disencd-terraform-test1/elb_logs/*",
          Principal: {
            "AWS": [
              data.aws_elb_service_account.main.id
            ]
          }
        }
      ]
    }
  )
}

resource "aws_default_vpc" "default" {
}
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-west-2a"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-west-2b"
  tags = {
    "Terraform" : "true"
  }
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
  count = 2

  ami           = "ami-0d60bcb3cd15a7c5b"
  instance_type = "t2.nano"

  vpc_security_group_ids = [
    aws_security_group.prod_web.id
  ]

  tags = {
    "Terraform" : "true"
  }
}

//resource "aws_eip" "prod_web" {
//  instance = aws_instance.prod_web_ec2.*.id
//
//  tags = {
//    "Terraform" : "true"
//  }
//}

resource "aws_elb" "prod_web" {
  name = "prod-web"
  subnets         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups = [aws_security_group.prod_web.id]

//  access_logs {
//    bucket        = aws_s3_bucket.prod_tf_s3.bucket
//    bucket_prefix = "elb"
//    interval      = 60
//  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_launch_template" "prod_web" {
  name_prefix   = "prod-web"
  image_id      = "ami-0d60bcb3cd15a7c5b"
  instance_type = "t2.nano"

  tags = {
    "Terraform" : "true"
  }
}

resource "aws_autoscaling_group" "prod_web" {
//  availability_zones = ["us-west-2a", "us-west-2b"]
  vpc_zone_identifier = [aws_default_subnet.default_az2.id, aws_default_subnet.default_az1.id]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.prod_web.id
    version = "$Latest"
  }

  tag {
    key = "Terraform"
    value = "true"
    propagate_at_launch = "true"
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "prod_web" {
  autoscaling_group_name = aws_autoscaling_group.prod_web.id
  elb = aws_elb.prod_web.id
}
