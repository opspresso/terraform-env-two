data "aws_caller_identity" "current" {}

# The default VPC of the region. Its subnets are public (an internet gateway route, no NAT), so the load balancers and
# the instances share them, and the deploy step gives the instances public addresses (argocd-env-projects
# charts/delivery/files/target.sh public_ip). The instance security group admits only the load balancer.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}
