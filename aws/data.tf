# Find the VPC by its Name tag
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["eks-tech-challenge-vpc"]
  }
}

# Find subnets for VPC Link
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

# Find the EKS Security Group
data "aws_security_group" "eks_cluster" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["eks-tech-challenge-cluster-sg"]
  }
}

# Find the EKS Load Balancer (ALB)
# Note: aws_lb data source does not support 'filter' blocks. 
# We use tags for discovery.
data "aws_lb" "eks_alb" {
  tags = {
    "elbv2.k8s.aws/cluster" = "eks-tech-challenge-cluster"
  }
}

# Find the ALB Listener (usually on port 80 for backend proxying)
data "aws_lb_listener" "eks_lb_listener" {
  load_balancer_arn = data.aws_lb.eks_alb.arn
  port              = 80
}

# Find IAM Role for AWS Academy
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Find Lambda functions
# data "aws_lambda_function" "authentication" {
#   function_name = "tech-challenge-user-authentication"
# }

data "aws_lambda_function" "authorizer" {
  function_name = "tech-challenge-user-authorizer"
}
