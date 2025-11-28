####################################
# 1. Security Group for ECS Tasks
####################################
resource "aws_security_group" "ecs_sg" {
  name        = "${var.env}-ecs-sg"
  description = "Allow only ALB to reach ECS tasks"
  vpc_id      = aws_vpc.main.id

  # Only ALB should reach ECS (port 8080)
  ingress {
    description     = "Allow ALB to access ECS tasks"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # ECS tasks can reach internet via NAT
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-ecs-sg"
  }
}


####################################
# 2. Security Group for ALB
####################################
resource "aws_security_group" "alb_sg" {
  name        = "${var.env}-alb-sg"
  description = "Allow public HTTP into ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-alb-sg"
  }
}


####################################
# 3. IAM Role — ECS Task Execution
####################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.env}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


####################################
# 4. ECS Cluster
####################################
resource "aws_ecs_cluster" "main" {
  name = "${var.env}-ecs-cluster"

  tags = {
    Name = "${var.env}-ecs-cluster"
  }
}


####################################
# 5. ECS Task Definition
####################################
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.env}-springboot-app"
  cpu                      = "256"              # 0.25 vCPU
  memory                   = "512"              # 512 MB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "springboot-app"
      image     = "deepaksom/accounts:s4"    # Your Docker Hub image
      essential = true

      portMappings = [
        {
          containerPort = 8080             # Spring Boot app port
          hostPort      = 8080
        }
      ]
    }
  ])
}


####################################
# 6. ECS Service
####################################
resource "aws_ecs_service" "app" {
  name            = "${var.env}-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2                        # High availability
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false                 # private subnets only
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "springboot-app"
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener.http
  ]
}
