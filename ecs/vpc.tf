locals {
  cluster_name = "${var.environment}-${var.name}-${random_string.suffix.result}"
  project_name = "${var.environment}-${var.name}"
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${local.project_name}-vpc"
  }
}

data "aws_subnets" "database" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    subnet-type = "database"
  }
}

data "aws_subnet" "database" {
  for_each = toset(data.aws_subnets.database.ids)
  id       = each.value
}

data "aws_subnets" "application" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    subnet-type = "application"
  }
}

data "aws_subnet" "application" {
  for_each = toset(data.aws_subnets.application.ids)
  id       = each.value
}

data "aws_subnets" "external-alb" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    subnet-type = "external-alb"
  }
}

data "aws_subnet" "external-alb" {
  for_each = toset(data.aws_subnets.external-alb.ids)
  id       = each.value
}
