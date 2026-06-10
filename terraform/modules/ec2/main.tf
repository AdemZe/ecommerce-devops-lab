# MODULE: EC2 INSTANCES
# Creates: IAM Role (SSM), EC2 instances, ALB attachments


locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ── IAM ROLE for EC2 (SSM + CloudWatch) ─────────────────────
resource "aws_iam_role" "ec2" {
  count = var.create_iam_resources ? 1 : 0
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.create_iam_resources ? 1 : 0
  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count      = var.create_iam_resources ? 1 : 0
  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  count = var.create_iam_resources ? 1 : 0
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2[0].name
}



# ── EC2 INSTANCES ────────────────────────────────────────────
resource "aws_instance" "web" {
  count = var.instance_count

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [var.ec2_sg_id]
  iam_instance_profile   = var.create_iam_resources ? aws_iam_instance_profile.ec2[0].name : var.existing_instance_profile_name

  # Minimal user-data — Ansible handles the rest
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3
  EOF
  )

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = { Name = "${local.name_prefix}-web-${count.index + 1}" }
}



# ── ATTACH INSTANCES TO TARGET GROUP ─────────────────────────
resource "aws_lb_target_group_attachment" "web" {
  count            = var.instance_count
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}