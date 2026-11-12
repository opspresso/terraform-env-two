# The network of the account. The Agent Runway eb target (two/8-runway-target, argocd-env-projects charts/delivery
# files/eb-stack.yaml) puts internet-facing load balancers in the public subnets and instances without public
# addresses in the private subnets. The instances reach Elastic Beanstalk, CloudFormation, SSM, CloudWatch Logs and the
# opspresso image registry through one NAT gateway; S3 (source bundles and image layers) goes through the free gateway
# endpoint instead. One NAT gateway is the cheapest managed egress. When its zone fails, instances in the other zone
# lose egress, while running apps keep serving.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-two"
  }
}

# No rule: nothing uses the default security group. Elastic Beanstalk makes each environment's own groups.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "vpc-two"
  }
}

resource "aws_subnet" "public" {
  for_each = var.az_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = "${var.region}${each.key}"
  cidr_block        = each.value.public

  tags = {
    Name = "vpc-two-public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.az_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = "${var.region}${each.key}"
  cidr_block        = each.value.private

  tags = {
    Name = "vpc-two-private-${each.key}"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "vpc-two-nat"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[var.nat_az].id

  tags = {
    Name = "vpc-two"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "vpc-two-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "vpc-two-private"
  }
}

resource "aws_route_table_association" "public" {
  for_each = var.az_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = var.az_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "vpc-two-s3"
  }
}
