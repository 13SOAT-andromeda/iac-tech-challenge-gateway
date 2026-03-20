terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "tech-challenge-bucket-andromeda-local"
    key    = "terraform-gateway.tfstate"
    region = "us-east-1"
    endpoints = {
      s3       = "http://localhost:4566"
      iam      = "http://localhost:4566"
      sts      = "http://localhost:4566"
      dynamodb = "http://localhost:4566"
    }
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = false
    use_path_style              = true
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = false
  s3_use_path_style           = true

  endpoints {
    ec2            = "http://localhost:4566"
    ecr            = "http://localhost:4566"
    rds            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    s3             = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    apigateway     = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "localstack"
      Project     = "tech-challenge"
    }
  }
}

module "api_gateway" {
  source                = "../modules/api-gateway"
  name                  = "tech-challenge-api-local"
  vpc_id                = data.aws_vpc.selected.id
  subnet_ids            = data.aws_subnets.private.ids
  security_group_ids    = [data.aws_security_group.eks_cluster.id]
  lb_listener_arn       = "arn:aws:elasticloadbalancing:us-east-1:000000000000:loadbalancer/net/mock-lb/1234567890abcdef"
  lab_role_arn          = "arn:aws:iam::000000000000:role/eks-local-role"
  auth_lambda_arn       = data.aws_lambda_function.auth.arn
  authorizer_lambda_arn = data.aws_lambda_function.authorizer.arn
  environment           = "localstack"
}
