# Creates: VPC, Internet Gateway, Public Subnets,
#          Private Subnets, NAT Gateway, Route Tables



local {
    name_prefix = "${var.project_name}-${var.environement}
}

# ── VPC ──────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${local.name_prefix}-vpc" }
}

# ── INTERNET GATEWAY ─────────────────────────────────────────
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${local.name_prefix}-igw" }
}

# ── PUBLIC SUBNETS (one per AZ) ──────────────────────────────
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)   #creer plusieurs ressources automatique 
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true   # ALB nodes need public IPs
                                   # Chaque nouvelle EC2 reçoit automatiquement une IP publique

  tags = { Name = "${local.name_prefix}-public-${count.index + 1}" }
}


# ── PRIVATE SUBNETS (one per AZ) ─────────────────────────────
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = { Name = "${local.name_prefix}-private-${count.index + 1}" }
}

# ── ELASTIC IP for NAT GW ────────────────────────────────────
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags       = { Name = "${local.name_prefix}-nat-eip" }
}

# ── NAT GATEWAY (placed in first public subnet) ──────────────
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags          = { Name = "${local.name_prefix}-nat-gw" }
}


# ── PUBLIC ROUTE TABLE ───────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${local.name_prefix}-rt-public" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

