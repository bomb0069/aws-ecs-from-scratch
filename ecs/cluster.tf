# terraform {
#   backend "s3" {
#     bucket = "terraform-bucket"
#     key    = "tfstate.tf"
#     region = var.region
#   }
# }

resource "aws_ecs_cluster" "cluster" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-${local.cluster_name}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "ecsAssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Cluster = local.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_full_access_s3_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# AWS Cloud Map
resource "aws_service_discovery_private_dns_namespace" "cluster_dns" {
  name        = local.cluster_name
  description = "private domain for ${local.cluster_name}"
  vpc         = data.aws_vpc.vpc.id
}

resource "aws_cloudwatch_log_group" "cluster" {
  name = local.cluster_name

  tags = {
    Environment = var.environment
    Application = local.cluster_name
  }
}
