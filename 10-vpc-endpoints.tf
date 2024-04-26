resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment}-vpc-endpoints"
  description = "Associated to ECR/s3 VPC Endpoints"
  vpc_id      = aws_vpc.todo_vpc.id

  ingress {
    description     = "Allow Nodes to pull images from ECR via VPC endpoints"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.todo_ecs_tasks.id]
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.todo_vpc.id
  service_name        = "com.amazonaws.${var.default_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids         = aws_subnet.private.*.id

  tags = {
    "Name" = "${var.environment}-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.todo_vpc.id
  service_name        = "com.amazonaws.${var.default_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids         = aws_subnet.private.*.id

  tags = {
    "Name" = "${var.environment}-ecr-api"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.todo_vpc.id
  service_name      = "com.amazonaws.${var.default_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.todo_rt_private.*.id

  tags = {
    "Name" = "${var.environment}-s3"
  }
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = aws_vpc.todo_vpc.id
  service_name        = "com.amazonaws.${var.default_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids         = aws_subnet.private.*.id

  tags = {
    "Name" = "${var.environment}-secrets-manager"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = aws_vpc.todo_vpc.id
  service_name        = "com.amazonaws.${var.default_region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids         = aws_subnet.private.*.id

  tags = {
    "Name" = "${var.environment}-cloudwatch"
  }
}
