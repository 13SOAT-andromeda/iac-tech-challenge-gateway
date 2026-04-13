data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["eks-tech-challenge-local-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*-private-*"]
  }
}

data "aws_security_group" "eks_cluster" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["eks-tech-challenge-local-cluster-sg"]
  }
}

data "aws_lambda_function" "authentication" {
  function_name = "tech-challenge-user-authentication"
}

data "aws_lambda_function" "authorizer" {
  function_name = "tech-challenge-user-authorizer"
}
