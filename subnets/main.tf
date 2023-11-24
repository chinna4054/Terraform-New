resource "aws_subnet" "dev-public-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

   tags = {
    Name        = "dev-public-subnet"
    Environment = "Development"
   }
  
  # Add other public subnet configurations
}

resource "aws_subnet" "dev-private-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name         = "dev-private-subnet"
    Environment  = "Development"
  }
}
  # Add other private
# Define other resources or configurations related