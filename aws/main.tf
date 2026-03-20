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
  name                      = "tech-challenge-api"
  vpc_id                    = data.aws_vpc.selected.id
  subnet_ids                = data.aws_subnets.private.ids
  security_group_ids        = [data.aws_security_group.eks_cluster.id]
  lb_listener_arn           = data.aws_lb_listener.eks_lb_listener.arn
  lab_role_arn              = data.aws_iam_role.lab_role.arn
  # authentication_lambda_arn = data.aws_lambda_function.authentication.arn
  authorizer_lambda_arn     = data.aws_lambda_function.authorizer.arn
  environment               = "dev"
}
