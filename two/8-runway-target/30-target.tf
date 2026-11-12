# The roles, boundary and bucket of the eb target, from the module that the opspresso Target (terraform-env-opsp
# demo/8-runway-target) uses too. The opspresso roles (terraform-env-opsp demo/7-eks-shared) reach them only with Agent
# Runway's external ID: the Workflow steps assume the deploy role, and Agent Runway assumes the secrets role.
module "target" {
  source = "git::https://github.com/opspresso/terraform-env-opsp.git//modules/runway-target?ref=d89bf8a71982cc05f0057106a2b79f2fe6fdf925"

  target_names         = [var.target_name]
  target_step_role_arn = "arn:aws:iam::${var.management_account_id}:role/pod-role--delivery-target"
  runway_role_arn      = "arn:aws:iam::${var.management_account_id}:role/pod-role--agent-runway"
  external_id          = var.runway_external_id
  domain               = local.domain
  hosted_zone_id       = local.zone_id
  secrets_key_arn      = aws_kms_key.variables.arn
  artifact_bucket      = "agent-runway-${var.target_name}-${local.account_id}"
}
