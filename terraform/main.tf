# main.tf - Main Terraform configuration
# ============================================
# Provider Configuration
# ============================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ============================================
# Data Sources
# ============================================

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================
# VPC Configuration
# ============================================

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ============================================
# Security Group Configuration
# ============================================

resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere (for future use)
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from your IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.206.107.24/29"]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}



# ============================================
# EC2 Instance Configuration
# ============================================

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]


  # Add this line:
  key_name               = "my-deploy-key"  # ← THIS LINE
 

  # User data script to install Docker and run the application
  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y
              
              # Install Docker
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              
              # Add ec2-user to docker group
              usermod -a -G docker ec2-user
              
              # Pull and run Docker container
              docker pull ${var.docker_image}
              docker run -d -p 80:5000 --name web-app --restart unless-stopped ${var.docker_image}
              
              # Create a simple status check script
              cat > /home/ec2-user/check-app.sh << 'SCRIPT'
              #!/bin/bash
              echo "Checking application status..."
              docker ps
              echo ""
              echo "Application logs:"
              docker logs web-app --tail 20
              SCRIPT
              
              chmod +x /home/ec2-user/check-app.sh
              EOF

  # Root volume configuration
  root_block_device {
    volume_size = 8 # GB - Free tier eligible
    volume_type = "gp2"
    encrypted   = true

    tags = {
      Name = "${var.project_name}-root-volume"
    }
  }

  # Enable detailed monitoring (optional, but useful)
  monitoring = true

  tags = {
    Name = "${var.project_name}-web-server"
  }

  # Ensure the instance is recreated if user_data changes
  user_data_replace_on_change = true
}

# ============================================
# Elastic IP (Optional - for static IP)
# ============================================

# Uncomment if you want a static IP that doesn't change on instance restart
# resource "aws_eip" "web_server" {
#   instance = aws_instance.web_server.id
#   domain   = "vpc"
#
#   tags = {
#     Name = "${var.project_name}-eip"
#   }
# }


