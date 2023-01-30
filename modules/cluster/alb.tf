
resource "aws_alb" "application_load_balancer" {
  name               = "${var.app_name}-${var.environment}-alb"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.environment
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.my_vpc.id

    dynamic "ingress" {
    for_each = local.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks  = ["0.0.0.0/0"]
    }
  }
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.app_name}-sg"
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "target_group" {
  name        = "${var.app_name}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.my_vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.app_name}-lb-tg"
    Environment = var.environment
  }
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "8888"
  protocol          = "HTTP"

   default_action {
    type             = "forward"
     target_group_arn = aws_alb_target_group.target_group.id
   }

}
 