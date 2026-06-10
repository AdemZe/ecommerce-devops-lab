
# ROOT VARIABLES — prod environment

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}


variable "project_name" {
  description = "Project name used in resource naming and tags"
  type        = string
  default     = "ecommerce-devops"
}


variable "environment" {
  description = "Deployment environment (prod / staging / dev)"
  type        = string
  default     = "prod"
}

# ── VPC ──────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "List of AZs to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ── EC2 ──────────────────────────────────────────────────────
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 web instances"
  type        = number
  default     = 2
}


variable "key_pair_name" {
  description = "Name of the existing EC2 Key Pair"
  type        = string
  # Set via terraform.tfvars or GitHub Secret
}

variable "ami_id" {
  description = "AMI ID (Amazon Linux 2 us-east-1)"
  type        = string
  default     = "ami-0c02fb55956c7d316"   # Amazon Linux 2 LTS — us-east-1
}

variable "create_iam_resources" {
  description = "Whether to create IAM role and instance profile in the EC2 module"
  type        = bool
  default     = false
}

variable "existing_instance_profile_name" {
  description = "Optional existing IAM instance profile name to attach to EC2 when IAM creation is disabled"
  type        = string
  default     = null
}


# ── ALB ──────────────────────────────────────────────────────
variable "health_check_path" {
  description = "ALB health check HTTP path"
  type        = string
  default     = "/"
}

# ── CloudWatch ───────────────────────────────────────────────
variable "alarm_email" {
  description = "Email address for CloudWatch CPU alarms"
  type        = string
  default     = "admin@example.com"
}

variable "cpu_alarm_threshold" {
  description = "CPU utilisation % that triggers the alarm"
  type        = number
  default     = 75
}
