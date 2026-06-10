# DESCRIPTION:
# Ce fichier "main.tf" compose les modules Terraform pour l'environnement "prod".
# Il assemble : VPC, security groups, ALB, EC2 et CloudWatch en passant des inputs
# (variables) aux modules et en consommant leurs outputs.
#
# D'où viennent les variables "var.*" utilisées ici ?
# - Les variables Terraform référencées comme var.project_name, var.environment, etc.
#   doivent être définies dans un fichier variables.tf situé dans ce répertoire
#   (terraform/envs/prod/variables.tf) ou héritées depuis un niveau supérieur
#   (ex. terraform/variables.tf). Les valeurs effectives sont fournies par :
#   - terraform.tfvars ou *.auto.tfvars dans ce répertoire, ou
#   - via la ligne de commande (-var), ou
#   - via des variables d'environnement TF_VAR_*
#
# D'où viennent les valeurs "module.*" (outputs) ?
# - Les références module.vpc.vpc_id, module.vpc.public_subnet_ids, module.ec2.instance_ids, etc.
#   sont des outputs exposés par les modules appelés (ex : ../../modules/vpc/outputs.tf).
#   Chaque module doit définir ses outputs pour être consommés ici.
#
# Notes rapides :
# - Les chemins "source = ../../modules/..." pointent vers les modules locaux du repo.
# - Les paramètres comme health_check_path, ami_id, instance_type viennent de var.*.
# - Les ressources réelles sont créées dans les modules ; ce fichier orchestre leur liaison.

# MAIN — Compose all modules

# ── 1. VPC ───────────────────────────────────────────────────
module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ── 2. SECURITY GROUPS ───────────────────────────────────────
module "security_groups" {
  source = "../../modules/security_groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id

}

# ── 3. ALB ───────────────────────────────────────────────────
module "alb" {
  source = "../../modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  health_check_path = var.health_check_path
}

# ── 4. EC2 ───────────────────────────────────────────────────
module "ec2" {
  source = "../../modules/ec2"

  project_name       = var.project_name
  environment        = var.environment
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  instance_count     = var.instance_count
  key_pair_name      = var.key_pair_name
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_sg_id          = module.security_groups.ec2_sg_id
  target_group_arn   = module.alb.target_group_arn
}


# ── 5. CLOUDWATCH ────────────────────────────────────────────
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name        = var.project_name
  environment         = var.environment
  instance_ids        = module.ec2.instance_ids
  alarm_email         = var.alarm_email
  cpu_alarm_threshold = var.cpu_alarm_threshold
}