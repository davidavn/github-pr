resource "github_repository_webhook" "repository_webhooks" {
  for_each = var.repository_names

  repository = each.value
  events     = ["push"]

  configuration {
    url          = aws_api_gateway_deployment.lambda.invoke_url
    content_type = "json"
  }
}
