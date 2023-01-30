# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
  
  tags = {
    Name = "${var.app_name}-${var.environment}-VPC"
  }
 
}

data "aws_availability_zones" "available" {}

# Create private subnets in two availability zone
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)

  vpc_id = aws_vpc.my_vpc.id
  cidr_block = element(var.private_subnet_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.app_name}-${var.environment}-private-${count.index + 1}"
  }
}
# Create public subnets in two availability zone
resource "aws_subnet" "public" {
 count = length(var.public_subnet_cidr)

  vpc_id = aws_vpc.my_vpc.id
  cidr_block = element(var.public_subnet_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}-${var.environment}-public-${count.index + 1}"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.app_name}-${var.environment}-gw"
  }
}
# Elastic IP for NAT
 resource "aws_eip" "nat_eip" {
  count = length(aws_subnet.public)

  vpc  = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.app_name}-${var.environment}-EIP"
  }
}
# Create NAT Gateway
resource "aws_nat_gateway" "nat" {
  count = length(aws_subnet.public)

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.app_name}-${var.environment}-GW"
  }

   #To ensure proper ordering, it is recommended to add an explicit dependency
   #on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#resource "aws_route" "private_nat_gateway" {
  #count       = length(aws_nat_gateway.nat)
  #route_table_id         = aws_route_table.private.id
  #destination_cidr_block = "0.0.0.0/0"
  #nat_gateway_id         = aws_nat_gateway.nat[count.index].id
#}

/*resource "aws_nat_gateway" "nat_gateway" {
  count = length(aws_subnet.public)
  connectivity_type = "private"
  subnet_id            = element(aws_subnet.public.*.id, count.index)
  #private_ip           = cidrhost(aws_subnet.public[count.index].cidr_block, count.index + 1)
  tags = {
    Name = "NatGateway"
  }
}*/

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.app_name}-${var.environment}-rt-public"
  }
}
# Create private route tables
resource "aws_route_table" "private" {
  count = length(aws_subnet.private)

  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    #gateway_id = aws_internet_gateway.igw.id
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }
  tags = {
    Name = "${var.app_name}-${var.environment}-rt-private"
  }
}

# Associate route table with public subnets
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id   = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate route table with private subnets
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id  = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
