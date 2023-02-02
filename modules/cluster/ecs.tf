resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.environment}-cluster"
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.app_name}-${var.environment}-logs"

  tags = {
    Application = var.app_name
    Environment = var.environment
  }
}

 resource "aws_ecs_task_definition" "aws-ecs-task" {
    family = "${var.app_name}-${var.environment}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.environment}-app",
      "image": "${local.image}",
      "entryPoint": [],
      "environment": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "${var.app_name}-${var.environment}"
        }
      },
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
    ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION 

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  tags = {
    Name        = "VERSION"
    Environment = var.image_tag
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-${var.environment}-ecs-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.aws-ecs-task.arn
  launch_type          = "FARGATE"
  desired_count        = 1

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.environment}-app"
    container_port   = 5000
  }

  depends_on = [aws_alb_listener.listener, aws_iam_role_policy.ecs_task_execution_role]
}

resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  
   dynamic "ingress" {
    for_each = local.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      security_groups = [aws_security_group.load_balancer_security_group.id]
    }
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-service-sg"
    Environment = var.environment
  }
}
