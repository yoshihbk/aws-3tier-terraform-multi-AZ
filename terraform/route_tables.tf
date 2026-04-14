# ---------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# ---------------------------------------------------------
# Public Route Table
# ---------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
  }
}

# ---------------------------------------------------------
# Public Route (0.0.0.0/0 → IGW)
# ---------------------------------------------------------
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ---------------------------------------------------------
# Route Table Association (public-subnet-1a)
# ---------------------------------------------------------
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------
# Route Table Association (public-subnet-1c)
# ---------------------------------------------------------
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------
# Elastic IP for NAT Gateway
# ---------------------------------------------------------
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "nat-eip"
  }
}

# ---------------------------------------------------------
# NAT Gateway (public-subnet-1a)
# ---------------------------------------------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name = "nat-gateway"
  }
}

# ---------------------------------------------------------
# Private Route Table
# ---------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }
}

# ---------------------------------------------------------
# Private Route (0.0.0.0/0 → NAT Gateway)
# ---------------------------------------------------------
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# ---------------------------------------------------------
# Route Table Association (private-subnet-1a)
# ---------------------------------------------------------
resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------
# Route Table Association (private-subnet-1c)
# ---------------------------------------------------------
resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_subnet_1c.id
  route_table_id = aws_route_table.private.id
}
