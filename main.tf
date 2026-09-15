resource "aws_vpc" "autoship" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "AutoShip"
    Environment = "Dev"
  }
}

resource "aws_subnet" "public_subnet1" {
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.autoship.id

  tags = {
    Name        = "AutoShip Public Subnet 1"
    Environment = "Dev"
  }
}


resource "aws_subnet" "public_subnet2" {
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.autoship.id

  tags = {
    Name        = "AutoShip Public Subnet 2"
    Environment = "Dev"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.autoship.id

  tags = {
    Name        = "autoship internet gateway"
    Environment = "Dev"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.autoship.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name        = "autoship public route table"
    Environment = "Dev"
  }
}

resource "aws_route_table_association" "public_route_table1" {
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.public_subnet1.id
}

resource "aws_ecr_repository" "image_registry" {
  name                 = "image-registry"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


# ECS cluster
resource "aws_ecs_cluster" "image_cluster" {
  name = "imageCluster"
}

# Fargate Tasks
data "aws_ecs_task_definition" "task" {
  task_definition = "autoship_task"
}

resource "aws_ecs_service" "service" {
  name = "autoship_service"
  cluster = aws_ecs_cluster.image_cluster.id
  task_definition = data.aws_ecs_task_definition.task.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.autoship_tg.arn 
    container_name = "autoship"
    container_port = 80
  }
}

resource "aws_alb" "autoship_alb" {
  name               = "autoshipAlb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

# 1. Security Group para el Balanceador de Carga (ALB) - Permite acceso web desde internet
resource "aws_security_group" "alb_sg" {
  name        = "autoship-alb-sg"
  description = "Permitir trafico HTTP y HTTPS"
  vpc_id      = aws_vpc.autoship.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Security Group para Fargate (ECS) - Solo permite tráfico que venga del ALB
resource "aws_security_group" "ecs_sg" {
  name        = "autoship-ecs-sg"
  description = "Permitir trafico exclusivamente desde el ALB"
  vpc_id      = aws_vpc.autoship.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Target Group para el ECS Service
resource "aws_lb_target_group" "autoship_tg" {
  name        = "autoship-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.autoship.id
  target_type = "ip"

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Environment = "Dev"
  }
}

# Listener para el ALB (necesario para que el balanceador reciba tráfico en el puerto 80 y lo mande al Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.autoship_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.autoship_tg.arn
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name = "goldgym.work.gd"
   subject_alternative_names = ["www.goldgym.work.gd"]
  validation_method = "DNS"
}

resource "aws_appautoscaling_target" "autoscale" {
  max_capacity = 3
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.image_cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}