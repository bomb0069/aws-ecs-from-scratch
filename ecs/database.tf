resource "aws_ecs_task_definition" "db" {
  family                   = "${var.name}-db"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "${var.name}-db"
      image     = "517425940836.dkr.ecr.ap-southeast-1.amazonaws.com/sample-database:0.0.1"
      cpu       = 10
      memory    = 512
      essential = true
      environment = [
        {
          name  = "POSTGRES_USER"
          value = "root"
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = "${aws_secretsmanager_secret_version.db_password.secret_string}"
        },
        {
          name  = "POSTGRES_DB"
          value = "${local.project_name}"
        },
      ]
      portMappings = [
        {
          containerPort = 5432
          hostPort      = 5432
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.cluster_name}"
          awslogs-region        = "${var.region}"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "database"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "db" {
  name            = "${var.name}-db"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.db.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnets.database.ids
    security_groups  = [aws_security_group.database.id]
    assign_public_ip = true
  }
  service_registries {
    registry_arn   = aws_service_discovery_service.db.arn
    container_name = "${var.name}-db"
  }
}

resource "aws_service_discovery_service" "db" {
  name = "db"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cluster_dns.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_security_group" "database" {
  name   = "security-group-database-for-${local.cluster_name}"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    self            = true
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.adminer.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_task_definition" "adminer" {
  family                   = "${var.name}-adminer"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name              = "${var.name}-adminer"
      image             = "adminer"
      cpu               = 1
      memoryReservation = 128
      essential         = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.cluster_name}"
          awslogs-region        = "${var.region}"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "adminer"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "adminer" {
  name            = "${var.name}-adminer"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.adminer.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnets.application.ids
    security_groups  = [aws_security_group.adminer.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.adminer-lb-target-group.arn
    container_name   = "${var.name}-adminer"
    container_port   = 8080
  }
}

resource "aws_security_group" "adminer" {
  name   = "security-group-adminer-for-${local.cluster_name}"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.name}-nginx"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name              = "${var.name}-nginx"
      image             = "nginx"
      cpu               = 1
      memoryReservation = 128
      essential         = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.cluster_name}"
          awslogs-region        = "${var.region}"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "nginx"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "nginx" {
  name            = "${var.name}-nginx"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnets.application.ids
    security_groups  = [aws_security_group.nginx.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx-lb-target-group.arn
    container_name   = "${var.name}-nginx"
    container_port   = 80
  }
}

resource "aws_security_group" "nginx" {
  name   = "security-group-nginx-for-${local.cluster_name}"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_ecs_task_definition" "httpd" {
  family                   = "${var.name}-httpd"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name              = "${var.name}-httpd"
      image             = "httpd"
      cpu               = 1
      memoryReservation = 128
      essential         = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.cluster_name}"
          awslogs-region        = "${var.region}"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "httpd"
        }
      }

    }
  ])
}

resource "aws_ecs_service" "httpd" {
  name            = "${var.name}-httpd"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.httpd.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnets.application.ids
    security_groups  = [aws_security_group.httpd.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.httpd-lb-target-group.arn
    container_name   = "${var.name}-httpd"
    container_port   = 80
  }
}

resource "aws_security_group" "httpd" {
  name   = "security-group-httpd-for-${local.cluster_name}"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
