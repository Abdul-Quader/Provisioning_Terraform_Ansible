# Configure AWS Provider
provider "aws" {
  access_key = "AKIA6ODU3xxxxxxxxxxxxxx"
  secret_key = "Tb5JlDAhIcgUtvWYshxxxxxxxxxxxxxxxxxxxxxxxx"
  region     = var.aws_region # Use the variable for region
}

# Define Variables (Optional, but good practice)
variable "aws_region" {
  default = "ap-south-1"
}

# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a" # Update with your desired zone
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

# Attach the internet gateway to the VPC
//resource "aws_vpc_endpoint" "internet" {
  //vpc_id       = aws_vpc.my_vpc.id
  //service_name = "aws-internet-gateway"
  //service_name = "com.amazonaws.ap-south-1.gateway"
  // route_table_ids = aws_internet_gateway.gateway.route_table_id
//}

# Create a security group allowing SSH access
resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update for specific IP range if desired
  }
}

resource "aws_instance" "my_instance" {
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

//  vpc_subnet_id = aws_subnet.public_subnet.id

  # AMI (Machine Image) selection
  ami = "ami-0cc9838aa7ab1dce7"

  # Instance type selection
  instance_type = "t2.micro"

  # Tags for the instance
  tags = {
    Name = "My Instance"
  }
}
