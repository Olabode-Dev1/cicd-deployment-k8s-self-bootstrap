# AWS provider configuration
provider "aws" {
  region  = "us-east-1"
  profile = "olabode"
}

# Create default VPC if one does not exist
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}

# Get all availability zones in the region
data "aws_availability_zones" "available_zones" {}

# Create default subnet if one does not exist
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

# Create security group for the EC2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "http access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
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
    Name = "Docker server security group"
  }
}

# Create security group for the Kubernetes servers
resource "aws_security_group" "k8s_server_urls" {
  name        = "k8s security group"
  description = "allow access on multiple ports"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "http proxy access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "sonarqube port access"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http proxy-nginx access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http nginx access"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "k8s access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "k8s1 access"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "k8s2 access"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "k8s3 access"
    from_port   = 31111
    to_port     = 31111
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
    Name = "K8s server security group"
  }
}

# Get a registered Ubuntu AMI
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

  owners = ["099720109477"]
}

# Launch the EC2 instance for Docker server
resource "aws_instance" "ec2_instance1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3a.large"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "virginia kp"
  user_data              = file("docker-install.sh")

  tags = {
    Name = "Docker-server"
  }
}

# Launch the EC2 instances for Kubernetes servers
resource "aws_instance" "k8s_server_urls" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.k8s_server_urls.id]
  key_name               = "virginia kp"
  user_data              = file("install_k8s.sh")

  tags = {
    Name = "K8s-server-${count.index + 1}"
  }
}

# Output the URL of the Docker server
output "website_url" {
  value = "http://${aws_instance.ec2_instance1.public_dns}:8080"
}

# Output the URLs of the Kubernetes servers
output "k8s_server_urls" {
  value = [
    for instance in aws_instance.k8s_server_urls :
    "http://${instance.public_ip}"
  ]
}

