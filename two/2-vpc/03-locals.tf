locals {
  azs = sort(keys(var.az_subnets))

  tags = {
    Environment = "two"
    ManagedBy   = "Terraform"
    Project     = "terraform-env-two/two/2-vpc"
  }
}
