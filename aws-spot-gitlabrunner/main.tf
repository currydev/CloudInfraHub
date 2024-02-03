terraform {
  backend "http" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region     = var.aws_region
}

# Data sources
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "runner" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}
resource "aws_subnet" "runner" {
  vpc_id     = aws_vpc.runner.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "${var.name_prefix}-subnet"
  }
}
resource "aws_internet_gateway" "runner" {
  vpc_id = aws_vpc.runner.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}
resource "aws_route_table" "runner" {
  vpc_id = aws_vpc.runner.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.runner.id
  }

  tags = {
    Name = "${var.name_prefix}-rtb"
  }
}
resource "aws_route_table_association" "runner" {
  subnet_id      = aws_subnet.runner.id
  route_table_id = aws_route_table.runner.id
}


# Security groups
resource "aws_security_group" "runner" {
  name_prefix = "${var.name_prefix}-runner"
  description = "Allow GitLab Runner traffic"
  vpc_id      = aws_vpc.runner.id
  ingress {
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name_prefix = "${var.name_prefix}-ssh"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.runner.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "runner" {
  name_prefix = "${var.name_prefix}-runner"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "runner" {
  name_prefix = "${var.name_prefix}-runner"
  role        = aws_iam_role.runner.name
}
# Generate an SSH key pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public key to AWS
resource "aws_key_pair" "ssh" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.ssh.public_key_openssh
}

# Launch template for GitLab Runner Manager
resource "aws_launch_template" "runner" {
  name_prefix    = "${var.name_prefix}-runner"
  image_id       = data.aws_ami.ubuntu.id
  instance_type  = var.instance_type
  key_name       = var.ssh_key_name
  vpc_security_group_ids = [
    aws_security_group.runner.id,
    aws_security_group.ssh.id,
  ]
  user_data      = filebase64("userdata.sh")

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.ebs_volume_size
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.runner.name
  }
}

# Optionally, you can create an Auto Scaling group to manage the GitLab Runner instances

resource "aws_autoscaling_group" "runner" {
  desired_capacity   = 1
  max_size           = 1
  min_size           = 2
  vpc_zone_identifier         = [aws_subnet.runner.id] # Use the new subnet

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.runner.id
      }

      override {
        instance_type     = "t2.micro"
        weighted_capacity = "3"
      }
    }
  }
}