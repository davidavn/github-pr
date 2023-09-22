resource "aws_iam_role" "lambda_exec_role" {
  name = "github-webhook-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_write_policy" {
  name        = "s3-write-policy"
  description = "Policy for write access to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:putObject",
          "s3:getObject",
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::github-pr-metadata*"
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/lambda_function.zip"
}

resource "aws_lambda_function" "github_webhook_lambda" {
  filename         = "${path.module}/python/lambda_function.zip"
  function_name    = "github-webhook-function"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/python/lambda_function.zip")
}

resource "aws_lambda_function_url" "webhook_url" {
  function_name      = aws_lambda_function.github_webhook_lambda.function_name
  authorization_type = "NONE"
}
