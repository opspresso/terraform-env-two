# The roles, boundary and bucket of the account's eb targets, from the module that the opspresso Target (terraform-env-opsp
# demo/8-runway-target) uses too. The opspresso roles (terraform-env-opsp demo/7-eks-shared) reach them only with Agent
# Runway's external ID: the Workflow steps assume the deploy role, and Agent Runway assumes the secrets role.
module "runway_target" {
  source = "git::https://github.com/opspresso/terraform-env-opsp.git//modules/runway-target?ref=42c233d79c9d4c08181b9d343e75faed1655be2f"

  target_names         = var.environment_names
  target_step_role_arn = "arn:aws:iam::${var.management_account_id}:role/pod-role--delivery-target"
  runway_role_arn      = "arn:aws:iam::${var.management_account_id}:role/pod-role--agent-runway"
  external_id          = var.runway_external_id
  domain               = local.domain
  hosted_zone_id       = local.zone_id
  secrets_key_arn      = aws_kms_key.variables.arn
  # The bucket keeps the name it was created with; Agent Runway reads it from the account (artifactBucket).
  artifact_bucket = "agent-runway-two-eb-amd64-${local.account_id}"
}
