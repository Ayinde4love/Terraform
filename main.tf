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
variable "my_ip" {}
variable "instance_type" {}


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

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route{
   cidr_block= "0.0.0.0/0"
   gateway_id= aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name="${var.env-prefix}-main-rtb"
  }
   
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "${var.env-prefix}-igw"
  }
}

resource "aws_default_security_group" "default-sg" {

  vpc_id      = aws_vpc.myapp-vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    "name" = "${var.env-prefix}-sg"
  }

}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners= ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "terraform"

  user_data = file("entry-script.sh")
  tags = {
    "name" = "${var.env-prefix}-server"
  }

}


output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip 
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image
}



