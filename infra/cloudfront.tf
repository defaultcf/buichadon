resource "aws_cloudfront_distribution" "app" {
  enabled         = true
  is_ipv6_enabled = false
  aliases         = [local.main_domain]
  web_acl_id      = aws_wafv2_web_acl.app.arn

  origin {
    domain_name = aws_lb.app.dns_name
    origin_id   = "buichadon_i544c_me"

    custom_origin_config {
      http_port              = 80
      https_port             = 80
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "buichadon_i544c_me"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      headers      = ["Host", "Accept", "Authorization", "Referer", "CloudFront-Forwarded-Proto"]
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.main.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${local.project}-app"
  }
}

resource "aws_cloudfront_origin_access_control" "files" {
  name                              = "s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "files" {
  enabled         = true
  is_ipv6_enabled = false
  aliases         = [local.files_domain]

  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.files.id
    origin_id                = "files_mstdn_default_cf"
  }

  default_cache_behavior {
    target_origin_id       = "files_mstdn_default_cf"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      headers      = ["Accept", "Authorization", "Referer", "CloudFront-Forwarded-Proto"]
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.main.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${local.project}-files"
  }
}
