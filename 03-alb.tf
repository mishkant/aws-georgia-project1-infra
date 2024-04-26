resource "aws_lb" "todo_alb" {
  name               = "ToDo-App-ALB"
  subnets            = aws_subnet.public.*.id
  load_balancer_type = "application"
  security_groups    = [aws_security_group.todo_alb_sg.id]

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.todo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo_tgroup.arn
  }
}

resource "aws_lb_target_group" "todo_tgroup" {
  name        = "${var.app_name}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.todo_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "15"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "10"
    path                = "/healthcheck"
    unhealthy_threshold = "2"
  }
}
