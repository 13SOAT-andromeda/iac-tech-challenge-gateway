variable "name" {
  description = "Name for the HTTP API Gateway"
  type        = string
  default     = "eks-tech-challenge-vpc"
}

variable "vpc_id" {
  description = "VPC ID where the Load Balancer is located"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC (used for VPC Link security group egress)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the VPC Link"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for the VPC Link"
  type        = list(string)
}

variable "lb_listener_arn" {
  description = "ARN of the EKS Load Balancer Listener"
  type        = string
}

variable "lab_role_arn" {
  description = "ARN of the IAM LabRole"
  type        = string
}

variable "authentication_lambda_arn" {
  description = "ARN of the authentication Lambda function"
  type        = string
}

variable "authorizer_lambda_arn" {
  description = "ARN of the authorizer Lambda function"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, localstack)"
  type        = string
  default     = "dev"
}
