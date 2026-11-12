output "domain" {
  value = aws_route53_zone.this.name
}

output "zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "The value of target_domains[\"<domain>\"] in terraform-env-opsp demo/8-app-delivery."
  value       = aws_route53_zone.this.name_servers
}
