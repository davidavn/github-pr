resource "aws_s3_bucket" "github_metadata" {
  bucket = var.data_bucket
}

resource "aws_s3_bucket_cors_configuration" "github_metadata" {
  bucket = aws_s3_bucket.github_metadata.id

  cors_rule {
    allowed_origins = ["http://${aws_s3_bucket_website_configuration.website.website_endpoint}"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    expose_headers  = []
    max_age_seconds = 0
  }
}
resource "aws_s3_bucket" "website" {
  bucket = var.host_bucket
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website,
    aws_s3_bucket_public_access_block.website,
  ]

  bucket = aws_s3_bucket.website.id
  acl    = "public-read"
}


resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Principal" : "*",
        "Action" = [
          "s3:getObject",
        ],
        "Resource" = ["${aws_s3_bucket.website.arn}/*"]
      },
    ],
  })
}

resource "aws_s3_bucket_policy" "github_metadata_policy" {
  bucket = aws_s3_bucket.github_metadata.id

  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Principal" : "*",
        "Action" = [
          "s3:getObject",
        ],
        "Resource" = ["${aws_s3_bucket.github_metadata.arn}/*"]
      },
    ],
  })
}

resource "aws_s3_bucket_ownership_controls" "github_metadata" {
  bucket = aws_s3_bucket.github_metadata.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "github_metadata" {
  bucket = aws_s3_bucket.github_metadata.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "github_metadata" {
  depends_on = [
    aws_s3_bucket_ownership_controls.github_metadata,
    aws_s3_bucket_public_access_block.github_metadata,
  ]

  bucket = aws_s3_bucket.github_metadata.id
  acl    = "public-read"
}
