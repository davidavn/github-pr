resource "github_repository_webhook" "repository_webhooks" {
  for_each = var.repository_names

  repository = each.value
  events     = ["push"]

  configuration {
    url          = aws_lambda_function_url.webhook_url.function_url
    content_type = "json"
    # secret       = "your-webhook-secret"
  }
}
