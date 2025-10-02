# S3 Bucket

resource "aws_s3_bucket" "website_s3_bucket" {
  bucket = "s3-${var.domainname}"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.website_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "http-s3" {
  bucket = aws_s3_bucket.website_s3_bucket.id
  index_document {
    suffix = "index.html"
  }

}

data "aws_iam_policy_document" "acces_cloudfront" {
  statement {
    sid = "PublicReadOnlyAccess"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.website_s3_bucket.arn}/*",
    ]

  }
}

resource "aws_s3_bucket_policy" "website_s3_policy" {
  bucket = aws_s3_bucket.website_s3_bucket.id
  policy = data.aws_iam_policy_document.acces_cloudfront.json
}

resource "aws_s3_bucket_public_access_block" "publicaccess" {
  bucket = aws_s3_bucket.website_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# CloudFront Distribution

resource "aws_cloudfront_distribution" "website_cf_distribution" {
  enabled = true
  aliases = var.ssl_acm_certificate_arn != null ? concat([var.domainname], var.extra_cnames) : null
  origin {
    domain_name = aws_s3_bucket_website_configuration.http-s3.website_endpoint
    origin_id   = aws_s3_bucket.website_s3_bucket.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_s3_bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 3600
  }
  viewer_certificate {
    cloudfront_default_certificate = var.ssl_acm_certificate_arn == null ? true : false
    acm_certificate_arn            = var.ssl_acm_certificate_arn
    ssl_support_method             = var.ssl_acm_certificate_arn == null ? null : "sni-only"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

}

resource "aws_route53_record" "root_domain" {
  count   = var.create_dns && var.is_root ? 1 : 0
  zone_id = var.route53_hosted_zone_id
  name    = var.domainname
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cname_domain" {
  count   = var.create_dns && !var.is_root ? 1 : 0
  zone_id = var.route53_hosted_zone_id
  name    = var.domainname
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.website_cf_distribution.domain_name]
}

resource "aws_route53_record" "cname_domain_extra" {
  count   = var.create_dns && !length(var.extra_cnames) != 0 ? length(var.extra_cnames) : 0
  zone_id = var.route53_hosted_zone_id
  name    = var.extra_cnames[count.index]
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
