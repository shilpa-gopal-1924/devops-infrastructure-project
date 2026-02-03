output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web_server.public_dns
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ~/.ssh/devops-key.pem ec2-user@${aws_instance.web_server.public_ip}"
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_sg.id
}
