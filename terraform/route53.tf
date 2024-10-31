# Get the hosted zone details
data "aws_route53_zone" "primary" {
  name = var.domain_name
}

# Route 53 A Record for dev subdomain
resource "aws_route53_record" "dev_a_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [aws_instance.web_app_instance.public_ip]
}


output "route53_zone_id" {
  value = data.aws_route53_zone.primary.zone_id
}

output "dev_fqdn" {
  value = aws_route53_record.dev_a_record.fqdn
}
