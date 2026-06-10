# BACKEND — Terraform state in S3 + DynamoDB lock
# Allows collaborative work (terraform state locking)
###############################################################

terraform {
  
  backend "s3" {
    bucket         = "ecommerce-devops-tfstate"   # ← change to your bucket name
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ecommerce-tfstate-lock"      # ← DynamoDB table for state locking
  }
}