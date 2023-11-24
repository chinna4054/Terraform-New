variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "internet_gateway" {
  description = "Internet gateway for the VPC"
  default     = "my_ig"
}

# Define other variables as needed
