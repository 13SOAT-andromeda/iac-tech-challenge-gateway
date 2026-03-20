# IaC Tech Challenge - API Gateway

Infrastructure as Code (IaC) for setting up the API Gateway layer, supporting both standard AWS environments and local development via LocalStack. This component provides the entry point for the Tech Challenge microservices, including VPC Link integration and Lambda-based authorization.

## Project Structure

- `modules/`: Reusable Terraform modules.
  - `api-gateway/`: Configures the HTTP API Gateway, VPC Link, Lambda Authorizers, and routes.
- `aws/`: Root configuration for deploying to a real AWS environment (configured for AWS Academy/Lab roles).
- `localstack/`: Root configuration for local testing using LocalStack.

## Architecture Highlights

- **HTTP API Gateway:** Lightweight and cost-effective API management.
- **VPC Link:** Securely connects the API Gateway to private resources (like ALB) within the VPC.
- **Lambda Authorizer:** Custom request-based authorization using an external Lambda function.
- **Microservices Integration:** Proxies requests to internal services via VPC Link or direct Lambda integrations (e.g., `/login`).

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0+)
- [LocalStack](https://localstack.cloud/) (for local development)
- [AWS CLI](https://aws.amazon.com/cli/)
- [tflocal](https://github.com/localstack/terraform-local) (optional, for LocalStack convenience)

## Getting Started

### Local Development (LocalStack)

1. Start LocalStack:
   ```bash
   localstack start -d
   ```

2. Initialize and apply:
   ```bash
   cd localstack
   tflocal init
   tflocal apply
   ```

### AWS Deployment

1. Ensure your AWS credentials are configured (e.g., via AWS Academy CLI session).
2. Initialize and apply:
   ```bash
   cd aws
   terraform init
   terraform apply
   ```

## Configuration

The infrastructure expects several pre-existing resources (VPC, Subnets, Lambdas) which are typically fetched via `data` sources:
- **VPC & Subnets:** Labeled with `Project: tech-challenge`.
- **Auth Lambdas:** `tech-challenge-auth` and `tech-challenge-authorizer`.
- **IAM Role:** Uses `LabRole` for AWS deployments and `eks-local-role` for LocalStack.
