resource "aws_db_instance" "todo_postgres" {
  identifier             = "todo-${var.environment}-postgres"
  allocated_storage      = 10
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  db_name                = "flaskdb"
  username               = "foo"
  password               = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)["POSTGRES_PASSWORD"]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.todo_dbsg.name
  vpc_security_group_ids = [aws_security_group.todo_sg_rds.id]
}

resource "aws_db_subnet_group" "todo_dbsg" {
  name       = "postgres-subnet"
  subnet_ids = aws_subnet.todo_subnet_rds.*.id

  tags = {
    Name = "PostgreSQL DB subnet group"
  }
}

resource "aws_security_group" "todo_sg_rds" {
  name        = "rds-sg"
  vpc_id      = aws_vpc.todo_vpc.id
  description = "allow inbound access from the ECS only"

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.todo_ecs_tasks.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}