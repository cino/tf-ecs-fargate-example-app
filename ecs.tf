resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "${aws_ecs_cluster.ecs_cluster.name}-nginx-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 256
  memory = 512
  container_definitions = jsonencode([{
    name        = "${aws_ecs_cluster.ecs_cluster.name}-container",
    image       = "nginx:latest",
    essential   = true,
    environment = [],
    portMappings = [{
      protocol      = "tcp",
      containerPort = 80,
      hostPort      = 80
    }]
  }])

  depends_on = [
    aws_ecs_cluster.ecs_cluster
  ]
}

resource "aws_security_group" "ecs_service_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      aws_security_group.alb_sg.id
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  depends_on = [
    aws_security_group.alb_sg,
    aws_vpc.main
  ]
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs_service_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "${aws_ecs_cluster.ecs_cluster.name}-container"
    container_port   = 80
  }

  depends_on = [
    aws_security_group.ecs_service_sg,
    aws_ecs_cluster.ecs_cluster,
    aws_ecs_task_definition.nginx,
    aws_subnet.private
  ]
}
