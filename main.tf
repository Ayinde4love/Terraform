terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.37.0"
    }
  }
}

provider "aws" {
 region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "env-prefix" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}


resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name= "${var.env-prefix}-vpc"
  }
   
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone =var.avail_zone
  tags = {
    "Name" = "${var.env-prefix}-subnet-1"
  }

}



