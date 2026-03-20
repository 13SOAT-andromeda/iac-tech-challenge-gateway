# Find the VPC by its Name tag
data "aws_vpc" "selected" {
  count = var.vpc_id == "" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["eks-tech-challenge-vpc"]
  }
}

locals {
  vpc_id = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.selected[0].id
}

# Find subnets for VPC Link
data "aws_subnets" "private" {
  count = length(var.subnet_ids) == 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [locals.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*-private-*"]
  }
}

locals {
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.private[0].ids
}

# Find the EKS Security Group
data "aws_security_group" "eks_cluster" {
  count = length(var.security_group_ids) == 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [locals.vpc_id]
  }
  filter {
    name   = "tag:kubernetes.io/cluster/eks-tech-challenge-cluster"
    values = ["owned", "shared"]
  }
}

locals {
  security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : data.aws_security_group.eks_cluster[0].id
}

# Find the EKS Load Balancer (ALB)
data "aws_lb" "eks_alb" {
  count = var.lb_listener_arn == "" ? 1 : 0
  tags = {
    "kubernetes.io/cluster/eks-tech-challenge-cluster" = "owned"
  }
}

# Find the ALB Listener
data "aws_lb_listener" "eks_lb_listener" {
  count             = var.lb_listener_arn == "" ? 1 : 0
  load_balancer_arn = data.aws_lb.eks_alb[0].arn
  port              = 80
}

locals {
  lb_listener_arn = var.lb_listener_arn != "" ? var.lb_listener_arn : data.aws_lb_listener.eks_lb_listener[0].arn
}

# Find IAM Role for AWS Academy
data "aws_iam_role" "lab_role" {
  count = var.lab_role_arn == "" ? 1 : 0
  name  = "LabRole"
}

locals {
  lab_role_arn = var.lab_role_arn != "" ? var.lab_role_arn : data.aws_iam_role.lab_role[0].arn
}

# Find Lambda functions
data "aws_lambda_function" "authentication" {
  count         = var.authentication_lambda_arn == "" ? 1 : 0
  function_name = "tech-challenge-user-authentication"
}

locals {
  authentication_lambda_arn = var.authentication_lambda_arn != "" ? var.authentication_lambda_arn : data.aws_lambda_function.authentication[0].arn
}

data "aws_lambda_function" "authorizer" {
  count         = var.authorizer_lambda_arn == "" ? 1 : 0
  function_name = "tech-challenge-user-authorizer"
}

locals {
  authorizer_lambda_arn = var.authorizer_lambda_arn != "" ? var.authorizer_lambda_arn : data.aws_lambda_function.authorizer[0].arn
}
