output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "public_subnets" {
  description = "The public subnets in availability zone order. Internet-facing load balancers use them."
  value       = [for az in local.azs : aws_subnet.public[az].id]
}

output "private_subnets" {
  description = "The private subnets in availability zone order. Instances without public addresses use them."
  value       = [for az in local.azs : aws_subnet.private[az].id]
}

output "nat_public_ips" {
  description = "The public addresses of the private subnets' outbound traffic, for allow lists of external services."
  value       = [aws_eip.nat.public_ip]
}
