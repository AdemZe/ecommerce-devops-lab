# Ce fichier définit les inputs du module EC2.
# Remarque générale : les valeurs de ces variables sont fournies par le root module
# (ex: terraform/envs/prod/main.tf) qui récupère soit :
# - des variables définies dans terraform/envs/prod/variables.tf ou terraform.tfvars,
# - des valeurs passées via la CLI (-var) ou TF_VAR_*,
# - ou des outputs d'autres modules (ex : private_subnet_ids venant du module vpc).

# Nom du projet — valeur typiquement définie dans envs/prod/variables.tf ou tfvars
variable "project_name"       { type = string }

# Environnement (prod/staging) — défini au niveau root
variable "environment"        { type = string }

# AMI à utiliser — peut être défini dans tfvars ou résolu via un data "aws_ami" au niveau root
variable "ami_id"             { type = string }

# Type d'instance — défini dans tfvars/root vars
variable "instance_type"      { type = string }

# Nombre d'instances — défini dans tfvars/root vars
variable "instance_count"     { type = number }

# Nom de la keypair AWS — défini dans tfvars/root vars
variable "key_pair_name"      { type = string }

# Liste d'IDs des subnets privés — fournie par le module VPC au root et passée ici :
#   root -> module.vpc.public_subnet_ids / private_subnet_ids -> module.ec2
variable "private_subnet_ids" { type = list(string) }

# ID du security group EC2 — fourni par le module security_groups via le root
variable "ec2_sg_id"          { type = string }

# ARN du target group ALB — fourni par le module alb via le root pour attacher les instances
variable "target_group_arn"   { type = string }

# AWS Academy often blocks IAM creation. Set to false to skip role/profile creation.
variable "create_iam_resources" {
	type    = bool
	default = true
}

# Optional pre-existing instance profile name to attach when create_iam_resources = false.
variable "existing_instance_profile_name" {
	type    = string
	default = null
}