# ============================================================================
# S3 MODULE FOR ASSETS STORAGE (images, PDFs, videos, etc.)
# ============================================================================

# S3 Bucket for assets
resource "aws_s3_bucket" "assets" {
  bucket = "${var.project}-${var.env}-assets"

  tags = {
    Name = "${var.project}-${var.env}-assets"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning (optional)
resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

# CloudFront Origin Access Control (OAC) - recommended over OAI
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.project}-${var.env}-s3-oac"
  description                       = "OAC for S3 assets bucket (images, PDFs, videos)"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 Bucket Policy to allow CloudFront access
resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.assets.id

  depends_on = [aws_s3_bucket_public_access_block.assets]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.assets.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}
