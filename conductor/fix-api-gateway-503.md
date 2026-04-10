# Fix API Gateway 503 Error and Lambda Authorizer Invocation

## Objective
Resolve the `503 Service Unavailable` error and ensure the Lambda authorizer is correctly invoked for private routes in the API Gateway.

## Background & Motivation
The user reported that routes requiring the Lambda authorizer (under `/api/{proxy+}`) return a `503 Service Unavailable` error and the authorizer is not being called. Analysis of the Terraform configuration revealed two primary causes:
1. **Lambda Invocation Permission:** The existing `aws_lambda_permission` for the authorizer uses a `source_arn` of `${execution_arn}/*/*`. While this grants permission for route-based integrations (like the `/api/authorize` endpoint, which works), it does not grant API Gateway permission to invoke the function *as an authorizer*. Authorizer invocations use a different ARN format (`.../authorizers/{authorizer_id}`).
2. **Invalid Backend Integration URI:** The `private` route forwards traffic to a backend integration configured as `HTTP_PROXY` over a `VPC_LINK`. However, the `integration_uri` is currently set to the Load Balancer Listener ARN (`var.lb_listener_arn`). For an `HTTP_PROXY` integration, this must be a fully qualified HTTP URL (e.g., `http://<alb-dns-name>`). The invalid ARN URI causes a 503 error when API Gateway attempts to route the request.

## Proposed Solution

### 1. Fix Lambda Permissions
Add a specific `aws_lambda_permission` resource in `modules/api-gateway/main.tf` to explicitly allow API Gateway to invoke the Lambda function as an authorizer.
```hcl
resource "aws_lambda_permission" "authorizer_invocation" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizerMetadata"
  action        = "lambda:InvokeFunction"
  function_name = var.authorizer_lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.this.id}"
}
```

### 2. Correct Backend Integration URI
Update the configuration to use the ALB's DNS name instead of the Listener ARN.
*   **`aws/data.tf`**: Extract the `dns_name` from the `data.aws_lb.eks_alb` resource.
*   **`aws/main.tf`**: Pass the `dns_name` as a new variable (e.g., `lb_dns_name`) to the `api_gateway` module.
*   **`modules/api-gateway/variables.tf`**: Add the `lb_dns_name` variable.
*   **`modules/api-gateway/main.tf`**: Update the `aws_apigatewayv2_integration.backend` to use `http://${var.lb_dns_name}` as the `integration_uri`.

## Alternatives Considered
*   Modifying the existing `/*/*` permission to `/*`: This might be too broad and it's best practice to use specific ARNs for authorizers.
*   Keeping the ARN and changing the integration type: API Gateway HTTP APIs require a URI for `HTTP_PROXY` via VPC Link; there is no alternative integration type that accepts an ARN for this use case.

## Implementation Steps
1. Update `aws/data.tf` to expose the ALB DNS name.
2. Update `aws/variables.tf` and `modules/api-gateway/variables.tf` to replace `lb_listener_arn` with `lb_dns_name` (or add it alongside).
3. Update `aws/main.tf` and `localstack/main.tf` to pass the new variable.
4. Update `modules/api-gateway/main.tf` to use the DNS name in the integration URI and add the new `aws_lambda_permission`.

## Verification & Testing
*   Run `terraform plan` to ensure the changes are valid.
*   The user should test calling a private route (e.g., `/dev/api/products`) with a valid `Authorization` header to confirm the authorizer is called and the request is successfully routed to the backend.