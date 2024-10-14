# Purpose: Define the variables that will be used in the Terraform configuration
# variable "aws_region" {
#   description = "AWS region to deploy resources"
#   default     = "us-east-1"
# }

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
