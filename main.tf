# create an S3 bucket with some tags and public ACL

# policy should verify:
# - S3 buckets cannot have public ACL
# - All buckets need to have a tag "Owner"

terraform {
  required_version = "~> 0.12.0"

  backend "s3" {
    profile        = "yodo"
    bucket         = "tfstate-global-468871832330"
    key            = "sandbox/opa-terraform-demo/tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tfstate-lock-global"
    kms_key_id     = "alias/tfstate-global"
    encrypt        = true
  }
}

provider "aws" {
  version = "~> 2.70"
  region  = "ap-southeast-1"
  profile = "yodo"
}

resource "aws_s3_bucket" "b" {
  bucket_prefix = "opa-test-bucket-"
  acl           = "public"

  tags = {
    Service     = "example-service"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "b2" {
  bucket_prefix = "opa-test-bucket2-"
  acl           = "private"

  tags = {
    Service     = "example-service"
    Owner       = "me"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "b3" {
  bucket_prefix = "opa-test-bucket2-"
  acl           = "private"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Service = "example-service"
    Owner   = "some-team"
  }
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}
