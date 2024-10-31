# Purpose: Define the variables that will be used in the Terraform configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
}

#DataBase Key Name
variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "identifier" {
  description = "Identifier for the RDS database"
  type        = string
}
variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "username" {
  description = "Username"
  type        = string
}

variable "db_password" {
  description = "Password"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the Route 53 record"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch Logs log group"
  type        = string
}

variable "log_stream_name" {
  description = "Name of the CloudWatch Logs log stream"
  type        = string
}

variable "metrics_namespace" {
  description = "Namespace for the CloudWatch Metrics"
  type        = string
}