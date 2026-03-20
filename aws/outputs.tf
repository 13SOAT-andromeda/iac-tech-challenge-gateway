output "api_endpoint" {
  description = "The HTTP API endpoint"
  value       = module.api_gateway.api_endpoint
}

output "vpc_link_id" {
  description = "The ID of the VPC Link"
  value       = module.api_gateway.vpc_link_id
}
