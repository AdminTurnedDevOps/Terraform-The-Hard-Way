# terraform {
#   backend "s3" {
#     bucket = "terraform-states"
#     key    = "api-state.tfstate"
#     region = "us-east-1"
#   }
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#     }
#   }
# }

# provider "aws" {
#   region = "us-east-1"
# }

resource "aws_apigatewayv2_api" "private_api" {
  name          = "companya-private-api-${var.environment}"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = [
      "*"
    ]
    allow_methods = [
      "*"
    ]

  }

  disable_execute_api_endpoint = var.environment == "staging" ? true : false
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "companya.com"
  validation_method = "DNS"
}

resource "aws_apigatewayv2_authorizer" "auth" {
  api_id           = aws_apigatewayv2_api.private_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "privateapi-${var.environment}-auth"
}

resource "aws_apigatewayv2_domain_name" "private_api" {
  count = var.environment == "staging" ? 1 : 0

  domain_name = "companya.com"

    domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_stage" "private_api" {
  api_id      = aws_apigatewayv2_api.private_api.id
  name        = "$default"
  auto_deploy = true
  default_route_settings {
    throttling_burst_limit = 10
    throttling_rate_limit  = 10
  }
}

resource "aws_apigatewayv2_api_mapping" "private_api" {
  count = var.environment == "staging" ? 1 : 0

  api_id      = aws_apigatewayv2_api.private_api.id
  domain_name = aws_apigatewayv2_domain_name.private_api.0.id
  stage       = aws_apigatewayv2_stage.private_api.id
}

## Company A API
resource "aws_apigatewayv2_integration" "testapi" {
  api_id             = aws_apigatewayv2_api.private_api.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_home" {
  api_id             = aws_apigatewayv2_api.private_api.id
  route_key          = "GET /home"
  target             = "integrations/${aws_apigatewayv2_integration.testapi.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.auth.id
}