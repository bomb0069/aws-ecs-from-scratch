locals {
  cluster_name = "${var.environment}-${var.name}"
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "${local.cluster_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  database_subnets     = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  intra_subnets        = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = false

  private_subnet_tags = {
    subnet_type = "app"
  }

  public_subnet_tags = {
    subnet_type = "web"
  }

  intra_subnet_tags = {
    subnet_type = "intra"
  }

  database_subnet_tags = {
    subnet_type = "db"
  }

  tags = {
    "${local.cluster_name}" = "shared"
  }
}
