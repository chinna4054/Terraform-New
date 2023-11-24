provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source         = "/mnt/c/Users/chinn/.vscode/.terraform/modules/vpc"
  vpc_cidr_block = "10.0.0.0/16" 

}

module "subnets" {
  source = "/mnt/c/Users/chinn/.vscode/.terraform/modules/subnets"
  vpc_id = module.vpc.vpc_id
  
}
