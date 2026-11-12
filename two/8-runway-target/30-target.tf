# The roles, boundary and bucket of the eb target, from the module that the opspresso Target (terraform-env-opsp
# demo/8-runway-target) uses too. The opspresso roles (terraform-env-opsp demo/7-eks-shared) reach them only with Agent
# Runway's external ID: the Workflow steps assume the deploy role, and Agent Runway assumes the secrets role.
module "runway_target" {
  source = "git::https://github.com/opspresso/terraform-env-opsp.git//modules/runway-target?ref=3d1d2a54680e3174307f4788ef4f800e8241eddc"

  target_names         = [var.target_name]
  target_step_role_arn = "arn:aws:iam::${var.management_account_id}:role/pod-role--delivery-target"
  runway_role_arn      = "arn:aws:iam::${var.management_account_id}:role/pod-role--agent-runway"
  external_id          = var.runway_external_id
  domain               = local.domain
  hosted_zone_id       = local.zone_id
  secrets_key_arn      = aws_kms_key.variables.arn
  artifact_bucket      = "agent-runway-${var.target_name}-${local.account_id}"
}
