provider "aws"  {
    region = "ap-south-1"
    access_key = "AKIARI6A6GEZTP2B2J5O"
    secret_key = "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"
}

########################################
# vpc -- module
########################################
resource "aws_vpc" "dev-vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "chaikin-dev2"
    }
}


########################################
# Subnet -- module
########################################

resource "aws_subnet" "public-subnet" {
    vpc_id     = aws_vpc.dev-vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "dev2-public-subnet"
    }
}

resource "aws_subnet" "private-subnet" {
    vpc_id     = aws_vpc.dev-vpc.id
    cidr_block = "10.0.2.0/24"

    tags = {
        Name = "dev2-private-subnet"
    }
}

resource "aws_subnet" "dev-ecs-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = "10.0.8.0/24"

    tags = {
        Name = "dev-ecs-subnet-1"
    }
}

resource "aws_subnet" "rds-subnet-1" {
    vpc_id             = aws_vpc.dev-vpc.id
    cidr_block         = "10.0.3.0/24"
    availability_zone  = "ap-south-1a"
    tags = {
        Name = "rds-subnet-1a"
    }
  }

resource "aws_subnet" "rds-subnet-2" {
    vpc_id             = aws_vpc.dev-vpc.id
    cidr_block         = "10.0.4.0/24"
    availability_zone  = "ap-south-1b"

    tags = {
        Name = "rds-subnet-1b"
    }
}

resource "aws_subnet" "rds-subnet-3" {
    vpc_id             = aws_vpc.dev-vpc.id
    cidr_block         = "10.0.5.0/24"
    availability_zone  = "ap-south-1c"

    tags = {
        Name = "rds-subnet-1c"
    }
}
resource "aws_subnet" "alb-public-subnet" {
    vpc_id     = aws_vpc.dev-vpc.id
    cidr_block = "10.0.6.0/24"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "alb-public-subnet"
    }
}

resource "aws_subnet" "alb-private-subnet" {
    vpc_id     = aws_vpc.dev-vpc.id
    cidr_block = "10.0.7.0/24"
    availability_zone = "ap-south-1b"

    tags = {
        Name = "alb-private-subnet"
    }
}

#########################################
# rds subnet group  -- module
#########################################

resource "aws_db_subnet_group" "dev-rds-sng" {
  name        = "dev-rds-sng"
  description = "RDS subnet group for dev environment"

  subnet_ids = [
    aws_subnet.rds-subnet-1.id,
    aws_subnet.rds-subnet-2.id,
    aws_subnet.rds-subnet-3.id
  ]
}

############################################
# Egress only internet gate way -- module
############################################

resource "aws_egress_only_internet_gateway" "chaikin-dev2" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev2-egw"
  }
}

#######################################
# Internet gate way -- module
#######################################

resource "aws_internet_gateway" "dev2-igw" {
    vpc_id = aws_vpc.dev-vpc.id

    tags = {
        Name = "dev2-igw"
    }
}

#########################################
# Route table -- module
#########################################

resource "aws_route_table" "dev2-public-rtb" {
    vpc_id = aws_vpc.dev-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dev2-igw.id
    }


    tags = {
        Name = "Dev2-Public-RTB"
    }
}

resource "aws_route_table" "dev2-private-rtb" {
    vpc_id = aws_vpc.dev-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.dev2-nat.id
    }
    
    tags = {
        Name = "Dev2-Private-RTB"
    }
}

##########################################
# Route table association -- module
##########################################

resource "aws_route_table_association" "dev2-public" {
    subnet_id      = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.dev2-public-rtb.id

}

resource "aws_route_table_association" "dev2-private" {
    subnet_id = aws_subnet.private-subnet.id
    route_table_id = aws_route_table.dev2-private-rtb.id
}

#########################################
# EC2 instance -- module
#########################################

resource "aws_instance" "dev2-private-instance" {
    ami           = "ami-0c42696027a8ede58"
    instance_type = "t3a.micro"
    security_groups = [aws_security_group.dev2-sg.id]
    subnet_id     = aws_subnet.private-subnet.id

    tags = {
        Name = "dev-private-instance"
    }

}

resource "aws_instance" "dev2-public-instance" {
    ami                           = "ami-0c42696027a8ede58"
    instance_type                 = "t3a.micro"
    security_groups               = [aws_security_group.dev2-sg.id]
    subnet_id                     = aws_subnet.public-subnet.id
    associate_public_ip_address   = true

    tags = {
        Name = "dev-public-instance"
    }
}

#########################################
# Security groups -- module
#########################################

resource "aws_security_group" "dev2-rds-sg" {
    description = "allow inbound traffic"
    vpc_id      = aws_vpc.dev-vpc.id

    ingress {
        description = "postgresql"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]
        
    }

}

resource "aws_security_group" "dev2-sg" {
    description = "security group for ecs"
    vpc_id      = aws_vpc.dev-vpc.id

    ingress {
        description = "SSH from anywhere"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks  = ["183.82.107.253/32"]

        
    }

    ingress {
        description = "HTTP from anywhere"
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS from anywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]

    }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

    }

   tags = {
        Name = "dev-ec2-sg"
    }
}

resource "aws_security_group" "dev-ecs-sg" {
    name        = "dev-ecs-sg"
    description = "Security group for ECS instances"
    vpc_id      = aws_vpc.dev-vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "dev-ecs-sg"
    }
}


resource "aws_security_group" "alb-sg" {
    vpc_id = aws_vpc.dev-vpc.id
    description = "security group for alb"

    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port   = 443
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "alb-sg"
    }
}

########################################
# Elastic ip -- module
########################################

resource "aws_eip" "dev2-eip" {
     domain = "vpc"

     tags = {
        Name = "dev-eip"
     }

}

######################################
# NAT gate way -- module
######################################

resource "aws_nat_gateway" "dev2-nat" {
  allocation_id = aws_eip.dev2-eip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "dev-NAT"
  }

}

###########################################
# rds (data base) -- module
###########################################

resource "aws_db_instance" "dev-db" {
    allocated_storage   = 20
    storage_type         = "gp2"
    engine               = "postgres"
    engine_version       = "14.3"
    instance_class       = "db.t3.micro"
    identifier           = "dev-rds-1"
    username             = "chinna"
    password             = "MyPa$$w0rd123"
    skip_final_snapshot  = true
    vpc_security_group_ids = [aws_security_group.dev2-rds-sg.id]
    db_subnet_group_name = aws_db_subnet_group.dev-rds-sng.name

    storage_encrypted    = true
    backup_retention_period = 7
    backup_window        = "01:00-02:00"

}

############################################# 
# kms keys -- module
#############################################

resource "aws_kms_key" "dev-rds-kms-key" {
  description             = "kms-key-rds"
  deletion_window_in_days = 30
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "kms:*", 
        Resource = "*",
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "kms:Encrypt",
        Resource = "*",
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = "kms:Encrypt",
        Resource = "*",
      },
    ]
  })
}

######################################################
# load balancer (application load balancer) -- module
######################################################

resource "aws_lb" "dev-lb" {
    internal                   = false
    load_balancer_type         = "application"
    enable_deletion_protection = false

    subnets = [aws_subnet.alb-public-subnet.id,aws_subnet.alb-private-subnet.id]

    enable_http2          = true
    idle_timeout          = 60
    enable_cross_zone_load_balancing = true
    

    tags = {
        Name = "dev-alb"
    }

}

#########################################
# target group -- module
#########################################

resource "aws_lb_target_group" "dev-tg" {
    port       = 80
    protocol   = "HTTP"
    vpc_id     = aws_vpc.dev-vpc.id
    target_type = "instance"

    health_check {
        path                = "/aws/healthcheck"
        protocol            = "HTTP"
        port                = "80"
        interval            = 30
        timeout             = 10
        healthy_threshold   = 3
        unhealthy_threshold = 3

    }

    tags = {
        Name = "dev-tg"
    }
}

############################################
# alb and target group attachment -- module
############################################

resource "aws_lb_target_group_attachment" "dev-tg-attach" {
  target_group_arn = aws_lb_target_group.dev-tg.arn
  target_id        = aws_instance.dev2-public-instance.id
}

########################################
# ecr repository -- module
########################################

resource "aws_ecr_repository" "dev-ecr" {
    name = "dev-ecr-1"
}

#########################################
# ecs cluster -- module
#########################################

resource "aws_ecs_cluster" "dev-cluster" {
    name = "dev-cluster-1"
}

#########################################
# ecs task  iam role -- module
#########################################

resource "aws_iam_role" "dev-ecs-task-role" {
  name = "dev-ecs-task-role-1"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

###########################################
# ecs task definition -- module
###########################################

resource "aws_ecs_task_definition" "dev-task-definition" {
  family = "dev-task-family"
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.dev-ecs-task-role.arn

  requires_compatibilities = ["FARGATE"]
  cpu = "256" 
  memory = "0.5GB"  
  container_definitions = jsonencode([{
    name = "dev-container"
    image = aws_ecr_repository.dev-ecr.repository_url
    portMappings = [{
      containerPort = 80
      hostPort = 80
    }]
    memory = 512 
    cpu = 256     
  }])
}

###########################################
#ecs task exicution policy -- module
###########################################

resource "aws_iam_policy" "dev-ecs-execution-policy" {
  name_prefix = "dev-ecs-execution-policy-1"
  description = "Policy for ECS execution role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DescribeImages",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
      
    ]
  })
}

#############################################
# role and policy attachment -- module
#############################################

resource "aws_iam_role_policy_attachment" "ecs_execution_attachment" {
  policy_arn = aws_iam_policy.dev-ecs-execution-policy.arn
  role       = aws_iam_role.dev-ecs-task-role.name
}

############################################
# ecs service -- module
############################################

resource "aws_ecs_service" "dev_ecs_service" {
  name            = "dev-ecs-service"
  cluster         = aws_ecs_cluster.dev-cluster.id
  task_definition = aws_ecs_task_definition.dev-task-definition.arn
  launch_type     = "FARGATE"  

  network_configuration {
    subnets = [aws_subnet.dev-ecs-subnet-1.id]
    security_groups = [aws_security_group.dev-ecs-sg.id] 
  }


  desired_count  = 1
 
}

#############################################
#s3 bucket  -- module
#############################################

resource "aws_s3_bucket" "dev-s3-bucket" {
  bucket = "tiger-zinda-hai"  

  tags = {
    Name = "chaikin-dev-bucket"
    Environment = "Dev"
  }

}

