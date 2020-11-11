
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "main-igw"
  }
}


resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.zones[count.index]
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  availability_zone = var.zones[count.index]
  cidr_block        = var.private_subnets[count.index]


  tags = {
    Name = "private-subnet-${count.index}"
  }
}

resource "aws_eip" "this" {
  count = length(var.public_subnets)
  vpc   = var.vpc
  tags = {
    Name = "nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "this" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.this.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]
  depends_on    = [aws_internet_gateway.this]
  tags = {
    Name = "nat-gw-${count.index}"
  }
}

resource "aws_route_table" "this" {
  count  = length(var.route_tables_names)
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "route-table-${var.route_tables_names[count.index]}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.this[0].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.this[count.index + 1].id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.this[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "private" {
  count                  = length(var.private_subnets)
  route_table_id         = aws_route_table.this.*.id[count.index + 1]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.*.id[count.index]
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "security-web"
  description = "Allow ports 80 and 22 for nginx "
  vpc_id      = aws_vpc.this.id


  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "security-db"
  description = "Allow port 22 for nginx"
  vpc_id      = aws_vpc.this.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
  name        = "security-lb"
  description = "Allow port 80 for load balancer"
  vpc_id      = aws_vpc.this.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

