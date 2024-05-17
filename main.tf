provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "hello_world" {
  name = "hello-world-cluster"
}

resource "aws_ecs_task_definition" "hello_world" {
  family                = "hello-world-task"
  requires_compatibilities = ["FARGATE"]
  network_mode          = "awsvpc"
  cpu                    = 1024
  memory               = 512
  execution_role_arn   = arn:aws:iam::419577552919:role/ecs-task-execution-role
  container_definitions = jsonencode([
    {
      name      = "hello-world"
      image      = "${aws_ecr_repository.hello_world.repository_url}:latest"
      cpu        = 10
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.hello_world.name
  task_definition = aws_ecs_task_definition.hello_world.arn
  desired_count   = 1
  launch_type      = "FARGATE"
  network_configuration {
    awsvpc_configuration {
      subnets          = ["subnet-0c2abb33b571382db"]
      security_groups = [aws_security_group.hello_world.id]
      assign_public_ip = "ENABLED"
    }
  }
}

resource "aws_ecr_repository" "hello_world" {
  name                 = "hello-world-repo"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name        = "ecs-task-execution-role"
  description = " Execution role for ECS tasks"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "hello_world" {
  name        = "hello-world-sg"
  description = "Security group for hello world app"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
