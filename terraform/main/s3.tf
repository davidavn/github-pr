resource "aws_s3_bucket" "github_metadata" {
  bucket = "github-pr-metadata"
}

resource "aws_s3_bucket_cors_configuration" "github_metadata" {
  bucket = aws_s3_bucket.github_metadata.id

  cors_rule {
    allowed_origins = ["http://dav-website-bucket.s3-website.ca-central-1.amazonaws.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    expose_headers  = []
    max_age_seconds = 3600
  }
}
resource "aws_s3_bucket" "website" {
  bucket = "dav-website-bucket"
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
        "Resource" = ["arn:aws:s3:::dav-website-bucket/*"]
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
        "Resource" = ["arn:aws:s3:::github-pr-metadata/*"]
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


# resource "aws_iam_role" "read_role" {
#   name = "read-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "s3.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "s3_read_policy" {
#   name        = "s3-read-policy"
#   description = "Policy for read access to S3 bucket"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [

#           "s3:getObject",
#         ],
#         Effect   = "Allow",
#         Resource = "arn:aws:s3:::github-pr-metadata/*"
#       },
#     ],
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_read_policy_to_read_role" {
#   role       = aws_iam_role.read_role.name
#   policy_arn = aws_iam_policy.s3_read_policy.arn
# }
