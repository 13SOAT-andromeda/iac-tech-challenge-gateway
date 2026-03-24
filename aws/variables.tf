variable "name" {
  description = "Name for the HTTP API Gateway"
  type        = string
  default     = "tech-challenge-api"
}

variable "vpc_id" {
  description = "VPC ID where the Load Balancer is located"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for the VPC Link"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security groups for the VPC Link"
  type        = list(string)
  default     = ["sg-052b688d65b247624"]
}

variable "lb_tag_name" {
  description = "Name tag of the EKS Load Balancer"
  type        = string
  default     = "k8s-elb-a11292f030362464f9469b1e8e8d582f"
}

variable "lb_listener_arn" {
  description = "ARN of the EKS Load Balancer Listener"
  type        = string
  default     = ""
}

variable "lab_role_arn" {
  description = "ARN of the IAM LabRole"
  type        = string
  default     = ""
}

variable "authentication_lambda_arn" {
  description = "ARN of the authentication Lambda function"
  type        = string
  default     = ""
}

variable "authorizer_lambda_arn" {
  description = "ARN of the authorizer Lambda function"
  type        = string
  default     = ""
}

variable "vpc_tag_name" {
  description = "Name tag of the VPC"
  type        = string
  default     = "eks-tech-challenge-vpc"
}

variable "cluster_tag_name" {
  description = "Tag name used to identify EKS resources"
  type        = string
  default     = "eks-tech-challenge"
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, localstack)"
  type        = string
  default     = "dev"
}
