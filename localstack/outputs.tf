output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = module.api_gateway.api_endpoint
}
