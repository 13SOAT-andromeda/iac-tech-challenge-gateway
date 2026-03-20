# --- HTTP API Gateway ---

resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = "HTTP"
  description   = "HTTP API for tech-challenge services"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format          = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      status                  = "$context.status"
      protocol                = "$context.protocol"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      authorizerError         = "$context.authorizer.error"
    })
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api-gw/${aws_apigatewayv2_api.this.name}"
  retention_in_days = 7
}

# --- VPC Link for ALB Integration ---

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.name}-vpc-link"
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids
}

# --- Authorizer: Lambda Token Authorizer ---

resource "aws_apigatewayv2_authorizer" "this" {
  api_id                           = aws_apigatewayv2_api.this.id
  authorizer_type                  = "REQUEST"
  authorizer_uri                   = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.authorizer_lambda_arn}/invocations"
  name                             = "tech-challenge-authorizer"
  identity_sources                 = ["$request.header.Authorization"]
  authorizer_payload_format_version = "2.0"
  enable_simple_responses          = true
}

# --- Integrations ---

# 1. /login POST -> Auth Lambda
resource "aws_apigatewayv2_integration" "login" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.auth_lambda_arn}/invocations"
  payload_format_version = "2.0"
}

# --- Routes ---

resource "aws_apigatewayv2_route" "login" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "POST /login"
  target             = "integrations/${aws_apigatewayv2_integration.login.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.this.id
}

# --- Lambda Permission ---

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.authorizer_lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
