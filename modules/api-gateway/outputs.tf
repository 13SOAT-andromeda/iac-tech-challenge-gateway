output "api_endpoint" {
  description = "The HTTP API endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "vpc_link_id" {
  description = "The ID of the VPC Link"
  value       = aws_apigatewayv2_vpc_link.this.id
}
