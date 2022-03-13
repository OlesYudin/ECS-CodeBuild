# Create ECS Cluster
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.app_name}-${var.env}-cluster"
  tags = {
    Name        = "ECS-${var.app_name}"
    Environment = var.env
  }
}

# Add task definition to ECS Cluster
resource "aws_ecs_task_definition" "task-definition" {
  family                   = "${var.app_name}-${var.env}-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs-ecr-iam-role.arn
  execution_role_arn       = aws_iam_role.ecs-ecr-iam-role.arn
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "Passwd-gen",
      image     = "564667093156.dkr.ecr.us-east-2.amazonaws.com/test:latest",
      cpu       = 256,
      memory    = 512,
      essential = true # If essential true, when container crash - all task crash
    }
  ])


  # Required if use Fargate
  runtime_platform {
    operating_system_family = "LINUX" # The valid values for Amazon ECS tasks hosted on Fargate are LINUX, WINDOWS_SERVER_2019_FULL, and WINDOWS_SERVER_2019_CORE
    cpu_architecture        = "X86_64"
  }
}

# Execute task definition on created cluster
resource "aws_ecs_service" "password-generator" {
  name            = "${var.app_name}-${var.env}-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.task-definition.arn

  launch_type   = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets          = aws_subnet.public_subnet.*.id
    security_groups  = [aws_security_group.sg.id]
    assign_public_ip = true
  }
}

