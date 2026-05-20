data "aws_vpc" "selected" {
  count = var.vpc_id == "" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.vpc_tag_name]
  }
}

locals {
  vpc_id   = var.vpc_id != "" ? var.vpc_id : try(data.aws_vpc.selected[0].id, "")
  vpc_cidr = try(data.aws_vpc.selected[0].cidr_block, "10.0.0.0/16")
}

data "aws_subnets" "private" {
  count = length(var.subnet_ids) == 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*-private-*"]
  }
}

locals {
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : try(data.aws_subnets.private[0].ids, [])
}

data "aws_security_group" "eks_cluster" {
  count = length(var.security_group_ids) == 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = [var.cluster_tag_name]
  }
}

locals {
  security_group_ids = [for s in (length(var.security_group_ids) > 0 ? var.security_group_ids : try([data.aws_security_group.eks_cluster[0].id], [])) : s if s != "None" && s != ""]
}

data "aws_lb" "eks_alb" {
  count = var.lb_listener_arn == "" ? 1 : 0
  tags = {
    "ingress.k8s.aws/stack" = "default/tech-challenge-ingress"
  }
}

data "aws_lb_listener" "eks_lb_listener" {
  count             = var.lb_listener_arn == "" ? 1 : 0
  load_balancer_arn = try(data.aws_lb.eks_alb[0].arn, "")
  port              = 80
}

locals {
  lb_listener_arn = var.lb_listener_arn != "" ? var.lb_listener_arn : try(data.aws_lb_listener.eks_lb_listener[0].arn, "")
}

data "aws_iam_role" "lab_role" {
  count = var.lab_role_arn == "" ? 1 : 0
  name  = "LabRole"
}

locals {
  lab_role_arn = var.lab_role_arn != "" ? var.lab_role_arn : try(data.aws_iam_role.lab_role[0].arn, "")
}

data "aws_lambda_function" "authentication" {
  count         = var.authentication_lambda_arn == "" ? 1 : 0
  function_name = "tech-challenge-user-authentication"
}

locals {
  authentication_lambda_arn = var.authentication_lambda_arn != "" ? var.authentication_lambda_arn : try(data.aws_lambda_function.authentication[0].arn, "")
}

data "aws_lambda_function" "authorizer" {
  count         = var.authorizer_lambda_arn == "" ? 1 : 0
  function_name = "tech-challenge-user-authorizer"
}

locals {
  authorizer_lambda_arn = var.authorizer_lambda_arn != "" ? var.authorizer_lambda_arn : try(data.aws_lambda_function.authorizer[0].arn, "")
}
