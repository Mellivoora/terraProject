resource "aws_instance" "myinstance" {
    ami = "ami-09558250a3419e7d0"
    instance_type = "t2.micro"
    vpc_security_group_ids = [ "aws_security_group.mySG.id" ]
    user_data = <<EOF
		#!/bin/bash
        sudo apt-get update
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF
    tags = {
      "Name" = "Prod"
    }
}

resource "aws_security_group" "mySG" {
  name        = "mySG"

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
}

resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "myGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "mySub" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "MySub"
  }
}

resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.myGW.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.foo.id
  }

  tags = {
    Name = "myRT"
  }
}