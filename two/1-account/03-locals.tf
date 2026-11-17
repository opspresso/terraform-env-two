locals {
  # The bucket of every root's state in this account. It is made by hand before the first root (README "준비와 실행").
  state_bucket = "terraform-workshop-${var.account_id}"

  tags = {
    Environment = "two"
    ManagedBy   = "Terraform"
    Project     = "terraform-env-two/two/1-account"
  }
}
