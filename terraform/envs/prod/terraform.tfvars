
# terraform.tfvars — Override defaults for production


aws_region   = "us-east-1"
project_name = "ecommerce-devops"
environment  = "prod"

# VPC
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

# EC2
instance_type  = "t3.micro"
instance_count = 2
key_pair_name  = "ecommerce_keypair"   # Must match an existing EC2 Key Pair name in the target AWS account/region
create_iam_resources = false
# existing_instance_profile_name = "LabInstanceProfile"  # optional if your lab provides one

# ALB
health_check_path = "/health"

# CloudWatch
alarm_email         = "adem.daghrour07@gmail.com"
cpu_alarm_threshold = 75
