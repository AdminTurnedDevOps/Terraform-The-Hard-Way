# Build An API On AWS With Terraform

Now that you've gone through the basics of Terraform and setting up your first project, it's time to get started with your real-world scenario. You'll be creating a full-blown API within API gateway via AWS with routes using Terraform.

Inside of this module, you'll find:
- A `main.tf` file
- A `variables.tf` file

This README breaks down the `main.tf` file

## The API
First things first, it's all about building out the actual API inside of API gateway. The CORS rules along with the protocol type is specified. Notice how it's an API with the HTTP protocol.

```
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
```

## Certs
For the domain to be registered (companya.com), there needs to be an SSL cert. Because we're already in AWS, it makes sense to have a cert in AWS using ACM.

```
resource "aws_acm_certificate" "cert" {
  domain_name       = "companya.com"
  validation_method = "DNS"
}
```

## Authorize The API
This authorizer is actually a Lambda function. It's a Lambda that's set up as a custom authorizer to create the functionality for controlling access to the API. We specifiy the API that it's associated to, the authorized type, and the headers for authentication.

```
resource "aws_apigatewayv2_authorizer" "auth" {
  api_id           = aws_apigatewayv2_api.private_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "privateapi-${var.environment}-auth"
}
```

## Domain Name
The domain name of the API is the organizations domain name. In this case, we're using `companya.com`.

Notice the `if` statement logic here in the `count` parameter. 

```
resource "aws_apigatewayv2_domain_name" "private_api" {
  count = var.environment == "staging" ? 1 : 0

  domain_name = "companya.com"

    domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}
```

## API Stage Setup
A stage is a reference to a deployment, which is a snapshot of the API itself. You can configure stage settings to enable caching, configure logging, stage variables, canary releaes, and custom request throttling.

```
resource "aws_apigatewayv2_stage" "private_api" {
  api_id      = aws_apigatewayv2_api.private_api.id
  name        = "$default"
  auto_deploy = true
  default_route_settings {
    throttling_burst_limit = 10
    throttling_rate_limit  = 10
  }
}
```

## API Mapping
Mapping in API gateway is to transform an initial integration request. To do so, you need a mapping template. The mapping template is associated with the `Content-Type` for an HTTP request (the API being created here is for an HTTP protocol)

```
resource "aws_apigatewayv2_api_mapping" "private_api" {
  count = var.environment == "staging" ? 1 : 0

  api_id      = aws_apigatewayv2_api.private_api.id
  domain_name = aws_apigatewayv2_domain_name.private_api.0.id
  stage       = aws_apigatewayv2_stage.private_api.id
}
```

## API Routes
Last but not least, there are the actual routes. Think of a route like when you go to a web page. For example, if you look at my website (michaellevan.net), there's a route for my Advisory Services page. The route is `/advisory_services`. The full URL is then `https://michaellevan.net/advisory_services/`

There are also methods, like `GET` and `POST`. In this case, we're retrieving information, not creating information via the API, so we use the `GET` method.

```
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
```