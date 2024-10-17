# VPC Configuration
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"
  }
  depends_on = [
    aws_vpc.my_vpc,
  ]
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
  }
  depends_on = [
    aws_vpc.my_vpc,
  ]
}

# Application Security Group
resource "aws_security_group" "application_sg" {
  name        = "application-security-group"
  description = "Security group for web applications"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080 
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web_app_instance" {
  ami                    = var.ami_id
  instance_type         = var.instance_type 
  subnet_id             = aws_subnet.public_subnet[0].id 

  vpc_security_group_ids = [aws_security_group.application_sg.id]
  key_name = "packer-key"
  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # Prevent accidental termination
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "Web-App-Instance"
  }
}
