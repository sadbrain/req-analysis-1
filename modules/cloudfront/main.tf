# ============================================================================
# CLOUDFRONT MODULE WITH VPC ORIGINS
# ============================================================================

# CloudFront Function to strip /backend prefix
resource "aws_cloudfront_function" "strip_backend_prefix" {
  name    = "${var.project}-${var.env}-strip-backend-prefix"
  runtime = "cloudfront-js-2.0"
  comment = "Strip /backend prefix before forwarding to origin"
  publish = true
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      // Remove /backend prefix from URI
      request.uri = request.uri.replace(/^\/backend/, '');
      // If URI is empty after strip, set to /
      if (request.uri === '') {
        request.uri = '/';
      }
      return request;
    }
  EOT
}

# VPC Origin for ALB - Frontend (port 80)
resource "aws_cloudfront_vpc_origin" "alb_fe" {
  vpc_origin_endpoint_config {
    name                   = "${var.project}-${var.env}-alb-fe"
    arn                    = var.alb_arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "http-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }

  tags = {
    Name = "${var.project}-${var.env}-alb-fe-vpc-origin"
  }
}

# VPC Origin for ALB - Backend (port 8080)
resource "aws_cloudfront_vpc_origin" "alb_be" {
  vpc_origin_endpoint_config {
    name                   = "${var.project}-${var.env}-alb-be"
    arn                    = var.alb_arn
    http_port              = 8080
    https_port             = 443
    origin_protocol_policy = "http-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }

  tags = {
    Name = "${var.project}-${var.env}-alb-be-vpc-origin"
  }
}

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project}-${var.env} CDN"
  price_class     = "PriceClass_200" # US, Europe, Asia, Middle East, Africa
  
  # Custom domain aliases
  aliases = length(var.domain_names) > 0 ? var.domain_names : null

  # Frontend Origin (VPC Origin - port 80)
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb-fe"

    vpc_origin_config {
      vpc_origin_id = aws_cloudfront_vpc_origin.alb_fe.id
    }
  }

  # Backend Origin (VPC Origin - port 8080)
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb-be"

    vpc_origin_config {
      vpc_origin_id = aws_cloudfront_vpc_origin.alb_be.id
    }
  }

  # S3 Origin for assets (images, PDFs, videos, etc.)
  dynamic "origin" {
    for_each = var.s3_bucket_regional_domain_name != "" ? [1] : []
    content {
      domain_name              = var.s3_bucket_regional_domain_name
      origin_id                = "s3-assets"
      origin_access_control_id = var.s3_oac_id
    }
  }

  # Default behavior (Frontend) - Low TTL cache for testing
  default_cache_behavior {
    target_origin_id       = "alb-fe"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["Host"]
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 30  # 30 seconds cache for testing
    max_ttl     = 120 # 2 minutes max
  }

  # Backend behavior (simulate FE calling BE via CloudFront) - No cache
  ordered_cache_behavior {
    path_pattern           = "/backend/*"
    target_origin_id       = "alb-be"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin", "Sec-WebSocket-Key", "Sec-WebSocket-Version", "Sec-WebSocket-Protocol", "Sec-WebSocket-Extensions", "Authorization"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    # Attach function to strip /backend prefix
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.strip_backend_prefix.arn
    }
  }

  # Assets behavior (images, PDFs, CVs, videos) - Cache with high TTL
  dynamic "ordered_cache_behavior" {
    for_each = var.s3_bucket_regional_domain_name != "" ? [1] : []
    content {
      path_pattern           = "/uploads/*"
      target_origin_id       = "s3-assets"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true

      forwarded_values {
        query_string = false
        headers      = []
        cookies {
          forward = "none"
        }
      }

      min_ttl     = 0
      default_ttl = 604800   # 7 days for static assets
      max_ttl     = 31536000 # 1 year
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # Use ACM certificate if provided, otherwise use default CloudFront cert
    acm_certificate_arn      = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    ssl_support_method       = var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version = var.acm_certificate_arn != "" ? "TLSv1.2_2021" : "TLSv1"
    cloudfront_default_certificate = var.acm_certificate_arn == ""
  }

  tags = {
    Name = "${var.project}-${var.env}-cdn"
  }
}
