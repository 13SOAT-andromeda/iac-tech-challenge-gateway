terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key     = "terraform-gateway.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Project     = "tech-challenge"
    }
  }
}

module "api_gateway" {
  source                    = "../modules/api-gateway"
  name                      = var.name
  vpc_id                    = local.vpc_id
  subnet_ids                = local.subnet_ids
  security_group_ids        = local.security_group_ids
  lb_listener_arn           = local.lb_listener_arn
  lab_role_arn              = local.lab_role_arn
  authentication_lambda_arn = local.authentication_lambda_arn
  authorizer_lambda_arn     = local.authorizer_lambda_arn
  environment               = var.environment
}
