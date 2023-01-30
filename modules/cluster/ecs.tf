resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.Demo-type}-${var.environment}-ecs"
  tags = {
    Name        = "${var.Demo-type}-ecs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.Demo-type}-${var.environment}-logs"

  tags = {
    Application = var.Demo-type
    Environment = var.environment
  }
}

 resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.Demo-type}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.Demo-type}-${var.environment}-container",
      "image": "${var.ecr_name}:latest",
      "entryPoint": [],
      "environment": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "${var.Demo-type}-${var.environment}"
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
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name        = "${var.Demo-type}-ecs-td"
    Environment = var.environment
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.Demo-type}-${var.environment}-ecs-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = aws_ecs_task_definition.aws-ecs-task.arn
  launch_type          = "FARGATE"
  desired_count        = 2
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.Demo-type}-${var.environment}-container"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.listener]
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
    Name        = "${var.Demo-type}-service-sg"
    Environment = var.environment
  }
}
