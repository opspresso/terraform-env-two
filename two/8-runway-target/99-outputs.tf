# What an administrator enters in Agent Runway: the account nalbam-two and the eb target of the environment two. They
# hold no secret value; Agent Runway adds access.externalId itself and derives the role ARNs from the account ID. The
# tiers use var.amd64_instance_types in the order small, medium, large.
output "account" {
  value = {
    name           = "nalbam-two"
    cloud          = "aws"
    id             = local.account_id
    region         = var.region
    access         = { secretsRole = module.runway_target.secrets_role_arn }
    artifactBucket = module.runway_target.artifact_bucket
    secretsKeyArn  = aws_kms_key.variables.arn
  }
}

output "eb_target" {
  value = {
    type          = "eb"
    architectures = ["amd64"]
    domain        = local.domain
    sizes = {
      small  = { instanceTypes = { amd64 = var.amd64_instance_types[0] }, min = 1, max = 1 }
      medium = { instanceTypes = { amd64 = var.amd64_instance_types[1] }, min = 1, max = 2 }
      large  = { instanceTypes = { amd64 = var.amd64_instance_types[2] }, min = 2, max = 4 }
    }
    solutionStack       = var.solution_stack
    vpcId               = data.aws_vpc.default.id
    instanceSubnets     = local.subnets
    loadBalancerSubnets = local.subnets
    certificateArn      = aws_acm_certificate_validation.apps.certificate_arn
    hostedZoneId        = local.zone_id
  }
}
