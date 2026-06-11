# ecommerce-devops-lab

Projet DevOps complet pour une application e-commerce sur AWS, avec:

- Terraform pour le provisionnement infrastructure
- Ansible pour la configuration/deploiement applicatif
- GitHub Actions pour l'automatisation CI/CD

## Documentation

- Description PDF du projet: [docs/Mini-Projet IaaS v2.pdf](docs/Mini-Projet IaaS v2.pdf)

## Demarrage rapide

1. Configurer les variables Terraform dans `terraform/envs/prod/terraform.tfvars`.
2. Initialiser et appliquer Terraform dans `terraform/envs/prod`.
3. Deployer l'application avec Ansible via `ansible/deploy.yml`.

Consulter la documentation detaillee pour les etapes completes et les bonnes pratiques.

-------------------------------------------------------------------------------------------------------------------------

# Documentation detaillee du projet ecommerce-devops-lab

## 1. Vue d'ensemble

Ce projet met en place une chaine DevOps complete pour une application e-commerce :

- Provisionnement de l'infrastructure AWS avec Terraform
- Configuration des serveurs et deploiement applicatif avec Ansible
- Orchestration CI/CD avec GitHub Actions
- Supervision de base avec CloudWatch + alerting SNS

Objectif principal : automatiser le cycle "infra -> configuration -> deploiement applicatif -> verification" de bout en bout.

## 2. Architecture technique

### 2.1 Composants AWS provisionnes

Dans l'environnement `terraform/envs/prod`, Terraform compose les modules suivants :

- VPC
  - 1 VPC
  - 2 subnets publics
  - 2 subnets prives
  - 1 Internet Gateway
  - 1 NAT Gateway + EIP
- Security Groups
  - SG ALB (HTTP/HTTPS entrant depuis internet)
  - SG EC2 (HTTP/3000 depuis ALB, SSH)
- ALB
  - 1 Application Load Balancer public
  - 1 Target Group
  - 1 Listener HTTP:80
- EC2
  - N instances web (par defaut 2)
  - Attachement des instances au Target Group
  - Option IAM flexible (creation IAM activee/desactivee)
- CloudWatch
  - 1 topic SNS
  - 1 abonnement email
  - alarmes CPU par instance

### 2.2 Architecture applicative deployee

Le role Ansible `app` deploie un stack Docker Compose sur les EC2 :

- MongoDB (`mongo:6`)
- Application Node.js (`nodeapp`)
- Nginx reverse proxy (`nginx:alpine`) exposant le port 80

Flux HTTP :

1. Client -> ALB:80
2. ALB -> EC2 (instance target)
3. Nginx (conteneur) -> Node.js
4. Node.js -> MongoDB

## 3. Structure du depot

- `.github/workflows/pipline.yml` : pipeline CI/CD (deploy + destroy)
- `terraform/envs/prod` : composition des modules pour la prod
- `terraform/modules/*` : modules terraform reutilisables
- `ansible/deploy.yml` : playbook principal
- `ansible/roles/docker` : installation Docker + Compose
- `ansible/roles/app` : deploiement applicatif Compose + health check
- `docs/` : documentation projet

## 4. Prerequis

### 4.1 Outils locaux

- Terraform >= 1.5
- Ansible
- AWS CLI configuree
- Acces au compte AWS cible
- Cle SSH pour EC2 (key pair)

### 4.2 Prerequis AWS

- Bucket S3 pour l'etat Terraform distant
- Table DynamoDB pour le verrouillage Terraform
- Key Pair EC2 existante dans la meme region que le deploiement
- Droits IAM suffisants (ou utilisation d'un profile IAM existant si contraintes academiques)

## 5. Configuration Terraform

### 5.1 Variables importantes (`terraform/envs/prod/terraform.tfvars`)

- `aws_region`
- `project_name`
- `environment`
- `instance_type`
- `instance_count`
- `key_pair_name`
- `create_iam_resources`
- `existing_instance_profile_name` (optionnel)
- `health_check_path`
- `alarm_email`
- `cpu_alarm_threshold`

### 5.2 Backend distant

Le backend est configure dans `terraform/envs/prod/backend.tf` :

- S3 pour stocker le state
- DynamoDB pour le verrou

Adapter les noms du bucket et de la table avant execution.

## 6. Deploiement manuel (local)

### 6.1 Provisionner l'infrastructure

Depuis `terraform/envs/prod` :

```bash
terraform init
terraform validate
terraform plan -out=tfplan -var-file=terraform.tfvars
terraform apply -auto-approve tfplan
```

### 6.2 Recuperer les sorties utiles

```bash
terraform output
```

Sorties cle :

- `instance_public_ips`
- `instance_private_ips`
- `alb_dns_name`

### 6.3 Deployer l'application avec Ansible

1. Construire un inventaire avec les IP EC2 provisionnees.
2. Executer le playbook :

```bash
ansible-playbook -i inventory.ini ansible/deploy.yml --private-key ~/.ssh/<key>.pem -v
```

3. Verifier les services Docker sur les machines.
4. Tester l'URL `http://<alb_dns_name>`.

## 7. Pipeline CI/CD GitHub Actions

Le workflow `.github/workflows/pipline.yml` execute :

1. Job Terraform
- Init, Validate, Plan, Apply
- Verification/import de la key pair EC2
- Export des IP instances et ALB DNS

2. Job Ansible
- Installation des dependances
- Generation inventaire dynamique depuis outputs Terraform
- Execution du playbook Ansible

3. Job Destroy
- Destruction de l'infrastructure (mode manuel)

### 7.1 Secrets GitHub attendus

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_SESSION_TOKEN` (si necessaire)
- `EC2_KEY` (contenu de la cle privee)

## 8. Observabilite et verification

### 8.1 CloudWatch

- Alarme CPU par instance
- Notification email via SNS

### 8.2 Controles de sante

- Terraform expose l'ALB DNS
- Le role `app` attend un code HTTP 200 sur `/health` en local machine cible
- Nginx route `/health` vers Node.js

## 9. Points d'attention

- Les instances sont dans des subnets prives : adapter votre strategie d'acces SSH selon l'environnement reel (bastion, SSM, etc.).
- Le SG SSH est ouvert largement dans la version actuelle : restreindre en production.
- `create_iam_resources = false` est utile dans des environnements limites (ex. labs academiques).
- Verifier la coherence de nommage des utilisateurs SSH dans l'inventaire Ansible.

## 10. Commandes utiles

### Terraform

```bash
terraform fmt -recursive
terraform validate
terraform output
terraform destroy -auto-approve -var-file=terraform.tfvars
```

### Ansible

```bash
ansible -i inventory.ini web -m ping
ansible-playbook -i inventory.ini ansible/deploy.yml -v
```

## 11. Plan d'amelioration recommande

- Ajouter TLS (HTTPS) avec certificat ACM sur ALB
- Ajouter environnement `staging`
- Ajouter tests applicatifs post-deploiement dans la pipeline
- Ajouter durcissement securite (SG, IAM least privilege)
- Ajouter collecte logs centralisee

## 12. Lien PDF de description du projet

- Description PDF du projet: [docs/Mini-Projet IaaS v2.pdf](docs/Mini-Projet IaaS v2.pdf)
