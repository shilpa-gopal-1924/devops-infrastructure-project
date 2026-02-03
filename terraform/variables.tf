variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "devops-project"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "docker_image" {
  description = "Docker image to deploy (username/image:tag)"
  type        = string
  # You'll set this in terraform.tfvars
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # Free tier eligible
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "my_ip" {
  description = "Your IP address for SSH access (get from https://whatismyip.com)"
  type        = string
  # You'll set this in terraform.tfvars
}
