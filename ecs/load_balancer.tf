# resource "aws_internet_gateway" "gw" {
#   vpc_id = data.aws_vpc.vpc.id

#   tags = {
#     Name = "main"
#   }
# }

resource "aws_lb" "internet" {
  name               = "${local.cluster_name}-internet-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = data.aws_subnets.external-alb.ids

  enable_deletion_protection = false

  tags = {
    Environment = "${var.environment} environment"
  }
}

resource "aws_lb_target_group" "adminer-lb-target-group" {
  name        = "${local.cluster_name}-ad-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id
  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.internet.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-lb-target-group.arn
  }
}


resource "aws_security_group" "lb" {
  name   = "security-group-lb-for-${local.cluster_name}"
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


resource "aws_lb_listener_rule" "adminer" {
  listener_arn = aws_lb_listener.web.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.adminer-lb-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/adminer", "/adminer/*"]
    }
  }

}


resource "aws_lb_target_group" "nginx-lb-target-group" {
  name        = "${local.cluster_name}-ng-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id
}


resource "aws_lb_listener_rule" "httpd" {
  listener_arn = aws_lb_listener.web.arn
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.httpd-lb-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/httpd", "/httpd/*"]
    }
  }

}


resource "aws_lb_target_group" "httpd-lb-target-group" {
  name        = "${local.cluster_name}-hd-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id
}
