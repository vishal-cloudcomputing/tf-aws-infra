output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.my_vpc.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "application_security_group_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.application_sg.id
}

output "web_app_instance_id" {
  description = "The ID of the web application EC2 instance"
  value       = aws_instance.web_app_instance.id
}

output "web_app_instance_public_ip" {
  description = "The public IP address of the web application EC2 instance"
  value       = aws_instance.web_app_instance.public_ip
}

output "web_app_instance_private_ip" {
  description = "The private IP address of the web application EC2 instance"
  value       = aws_instance.web_app_instance.private_ip
}
