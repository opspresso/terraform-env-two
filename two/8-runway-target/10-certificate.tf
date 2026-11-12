# The certificate of the load balancers' HTTPS listener (eb-stack.yaml CertificateArn). App hosts have one label under
# the domain, so the wildcard covers them all. ACM resolves the validation record through rovr.dev, so the delegation
# (terraform-env-opsp demo/8-app-delivery target_domains) must exist before this root is applied.
resource "aws_acm_certificate" "apps" {
  domain_name       = "*.${local.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate_validation" {
  for_each = { for option in aws_acm_certificate.apps.domain_validation_options : option.domain_name => option }

  zone_id = local.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  ttl     = 300
  records = [each.value.resource_record_value]
}

resource "aws_acm_certificate_validation" "apps" {
  certificate_arn         = aws_acm_certificate.apps.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}
