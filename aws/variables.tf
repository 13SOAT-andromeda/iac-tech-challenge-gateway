variable "lb_listener_arn" {
  description = "The ARN of the ALB Listener created in EKS"
  type        = string
  default     = "arn:aws:elasticloadbalancing:us-east-1:186319076937:listener/app/placeholder/12345/67890"
}
