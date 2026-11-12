locals {
  account_id = data.aws_caller_identity.current.account_id
  # The app domain and its zone (two/3-domain). App hosts are <slug>.<domain> and <slug>-<env>.<domain>.
  domain  = data.terraform_remote_state.domain.outputs.domain
  zone_id = data.terraform_remote_state.domain.outputs.zone_id

  tags = {
    Environment = "two"
    ManagedBy   = "Terraform"
    Project     = "terraform-env-two/two/8-runway-target"
  }
}
