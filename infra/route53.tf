resource "aws_route53_zone" "main" {
  name = local.main_domain
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.id
  name    = local.main_domain
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "files" {
  zone_id = aws_route53_zone.main.id
  name    = local.files_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.files.domain_name
    zone_id                = aws_cloudfront_distribution.files.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "main" {
  domain_name               = "*.${local.main_domain}"
  subject_alternative_names = [local.main_domain]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = aws_route53_zone.main.id
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"
}
