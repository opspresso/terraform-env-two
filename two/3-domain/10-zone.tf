# The zone of the domain. Its parent zone rovr.dev in opspresso delegates it with these name servers (terraform-env-opsp
# demo/8-app-delivery target_domains), so a new zone needs a new delegation: the zone is kept from destruction.
resource "aws_route53_zone" "this" {
  name    = var.domain
  comment = "Delegated from rovr.dev (opspresso)"

  lifecycle {
    prevent_destroy = true
  }
}
