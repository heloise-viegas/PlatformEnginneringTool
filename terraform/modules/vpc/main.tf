# ─── VPC ──────────────────────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # Required for EKS node registration

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

# ─── Internet Gateway ──────────────────────────────────────────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# ─── Public Subnets ───────────────────────────────────────────────────────────
# Keyed by AZ (each.key = "ap-south-1a", each.value = "10.0.1.0/24")
resource "aws_subnet" "public" {
  for_each = var.pub_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-public-${each.key}"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ─── Private Subnets ──────────────────────────────────────────────────────────
resource "aws_subnet" "private" {
  for_each = var.priv_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-private-${each.key}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ─── Elastic IPs for NAT Gateways ─────────────────────────────────────────────
# One EIP per public subnet (keyed by AZ)
resource "aws_eip" "nat" {
  for_each = var.pub_subnets
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip-${each.key}"
  }

  depends_on = [aws_internet_gateway.main]
}

# ─── NAT Gateways (one per AZ for HA) ────────────────────────────────────────
resource "aws_nat_gateway" "main" {
  for_each = var.pub_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id # NAT GW lives in PUBLIC subnet

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-gw-${each.key}"
  }

  depends_on = [aws_internet_gateway.main]
}

# ─── Public Route Table ───────────────────────────────────────────────────────
# Single table shared by all public subnets — all go out via IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = var.pub_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# ─── Private Route Tables (one per AZ → each AZ's own NAT GW) ────────────────
# Separate table per AZ so each private subnet uses its local NAT GW.
# Avoids cross-AZ NAT traffic charges and single point of failure.
resource "aws_route_table" "private" {
  for_each = var.priv_subnets
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.priv_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
