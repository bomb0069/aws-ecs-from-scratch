provider "aws" {
  region = var.region
}

# terraform {
#   backend "s3" {
#     bucket = "terraform-bucket"
#     key    = "tfstate.tf"
#     region = var.region
#   }
# }

resource "aws_ecr_repository" "backend" {
  name                 = "${var.name}-backend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    name      = "${var.name}-backend"
    terraform = "true"
  }
}

resource "aws_ecr_repository_policy" "backend_policy" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Statement" : [
        {
          "Sid" : "AllowVeradigmAccountsToPullAdoBuilder",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::322484590997:root",
              "arn:aws:iam::517425940836:user/bomb-push-image"
            ]
          },
          "Action" : [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
          ]
        }
      ]
    }
  )
}


resource "aws_ecr_repository" "frontend" {
  name                 = "${var.name}-frontend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    name      = "${var.name}-frontend"
    terraform = "true"
  }
}

resource "aws_ecr_repository_policy" "frontend_policy" {
  repository = aws_ecr_repository.frontend.name

  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Statement" : [
        {
          "Sid" : "AllowVeradigmAccountsToPullAdoBuilder",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::322484590997:root",
              "arn:aws:iam::517425940836:user/bomb-push-image"
            ]
          },
          "Action" : [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
          ]
        }
      ]
    }
  )
}


resource "aws_ecr_repository" "database" {
  name                 = "${var.name}-database"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    name      = "${var.name}-database"
    terraform = "true"
  }
}

resource "aws_ecr_repository_policy" "database_policy" {
  repository = aws_ecr_repository.database.name

  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Statement" : [
        {
          "Sid" : "AllowVeradigmAccountsToPullAdoBuilder",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::322484590997:root",
              "arn:aws:iam::517425940836:user/bomb-push-image"
            ]
          },
          "Action" : [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
          ]
        }
      ]
    }
  )
}
