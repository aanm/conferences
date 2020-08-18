terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Make sure we select an AZ that has the instance type that we want
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "arm_dev_summit_terraform"
  description = "Used for ARM dev summit"
  vpc_id      = aws_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "auth-key"
  public_key = file(var.public_key_path)
}

//resource "aws_instance" "arm-dev" {
//  # The connection block tells our provisioner how to
//  # communicate with the resource (instance)
//  connection {
//    type = "ssh"
//    # The default username for our AMI
//    user = "ubuntu"
//    host = self.public_ip
//    private_key = file(var.private_key_path)
//    # The connection will use the local SSH agent for authentication.
//  }
//
//  # ARM instance type
//  instance_type = "a1.large"
//
//  # Ubuntu 20.04 for arm
//  ami = "ami-008680ee60f23c94b"
//
//  # The name of our SSH keypair we created above.
//  key_name = aws_key_pair.auth.id
//
//  # Our Security group to allow HTTP and SSH access
//  vpc_security_group_ids = [
//    aws_security_group.default.id]
//
//  subnet_id = aws_subnet.default.id
//
//  provisioner "file" {
//    source = "scripts"
//    destination = "/tmp/provision"
//  }
//
//  provisioner "remote-exec" {
//    inline = [
//      "sudo chmod 755 /tmp/provision/*.sh",
//      "sudo /tmp/provision/install.sh",
//    ]
//  }
//}

resource "aws_instance" "arm-dev-workshop" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    type = "ssh"
    # The default username for our AMI
    user = "ubuntu"
    host = self.public_ip
    private_key = file(var.private_key_path)
    # The connection will use the local SSH agent for authentication.
  }

  count = var.number_of_attendees

  # ARM instance type
  instance_type = "a1.large"

  # Ubuntu 20.04 for arm based on the aws_instance created above
  ami = "ami-060e6238c4f5f29c7"

  # The name of our SSH keypair we created above.
  key_name = aws_key_pair.auth.id

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [
    aws_security_group.default.id]

  subnet_id = aws_subnet.default.id

  provisioner "file" {
    source = "scripts"
    destination = "/tmp/provision"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 755 /tmp/provision/*.sh",
      "sudo /tmp/provision/init.sh",
    ]
  }
}
