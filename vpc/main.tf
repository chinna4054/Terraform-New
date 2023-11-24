resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags  = {
    Name = "chaikin-dev"
  }
  # Add other VPC configurations
}

# Define other resources or configurations related to the VPC