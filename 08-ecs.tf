data "template_file" "todo_app" {
  template = file("task-definition/service.json.tpl")
  vars = {
    aws_ecr_repository            = aws_ecr_repository.todo_app.repository_url
    tag                           = "latest"
    container_name                = var.app_name
    aws_cloudwatch_log_group_name = aws_cloudwatch_log_group.todo_app.name
    database_address              = aws_db_instance.todo_postgres.address
    database_name                 = aws_db_instance.todo_postgres.db_name
    postgres_username             = aws_db_instance.todo_postgres.username
    postgres_password             = "${data.aws_secretsmanager_secret.postgresql_password_secret.id}:POSTGRES_PASSWORD::"
  }
}

resource "aws_ecs_task_definition" "app_ecs_task_definition" {
  family                   = "${var.app_name}-${var.environment}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.todo_app.rendered
  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_ecs_cluster" "cluster_staging" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_service" "app_staging" {
  name                       = "todo-app-${var.environment}"
  cluster                    = aws_ecs_cluster.cluster_staging.id
  task_definition            = aws_ecs_task_definition.app_ecs_task_definition.arn
  desired_count              = 2
  deployment_maximum_percent = 250
  launch_type                = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.todo_ecs_tasks.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.todo_tgroup.arn
    container_name   = var.app_name
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.https_forward, aws_iam_role_policy.ecs_task_execution_role]

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}
