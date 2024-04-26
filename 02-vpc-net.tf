data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "todo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "todo_vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.todo_vpc.cidr_block, 8, 2 + count.index) #10.0.2.0/24 10.0.3.0/24
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.todo_vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name = "todo_public_subnet_${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.todo_vpc.cidr_block, 8, count.index) #10.0.0.0/24 10.0.1.0/24
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.todo_vpc.id

  tags = {
    Name = "todo_private_subnet_${count.index}"
  }
}

resource "aws_subnet" "todo_subnet_rds" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.todo_vpc.cidr_block, 8, 4 + count.index)   #10.0.4.0/24, 10.0.5.0/24
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.todo_vpc.id

  tags = {
    Name = "todo_rds_subnet_${count.index}"
  }
}

resource "aws_internet_gateway" "todo_ig_gateway" {
  vpc_id = aws_vpc.todo_vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.todo_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.todo_ig_gateway.id
}

resource "aws_route_table" "todo_rt_private" {
  count  = 2
  vpc_id = aws_vpc.todo_vpc.id

  tags = {
    Name = "todo_route_table_${count.index}"
  }
}

resource "aws_route_table_association" "todo_rt_association_private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.todo_rt_private.*.id, count.index)
}

resource "aws_route_table_association" "todo_rt_association_rds" {
  count          = 2
  subnet_id      = element(aws_subnet.todo_subnet_rds.*.id, count.index)
  route_table_id = element(aws_route_table.todo_rt_private.*.id, count.index)
}