variable "region" {
  description = "The Target region."
  type        = string
  default     = "ap-northeast-2"
}

variable "account_id" {
  description = "The account nalbam-two. The provider refuses credentials of any other account."
  type        = string
  default     = "552292899126"
}

variable "management_account_id" {
  description = "The account of Agent Runway and the EKS cluster that runs its Workflows (opspresso, eks-demo)."
  type        = string
  default     = "396608815058"
}

variable "runway_external_id" {
  description = "account.access.externalId of the Agent Runway environment two (Agent Runway console 관리 > 환경 > two). Agent Runway generates it; keep it out of Git."
  type        = string
  nullable    = false

  validation {
    # RE2 allows at most 1000 repetitions, so the length is checked apart.
    condition     = length(var.runway_external_id) >= 2 && length(var.runway_external_id) <= 1224 && can(regex("^[A-Za-z0-9_+=,.@:/-]+$", var.runway_external_id))
    error_message = "runway_external_id must be an STS external ID: 2-1224 characters of A-Z, a-z, 0-9 and _+=,.@:/-."
  }
}

variable "target_name" {
  description = "The name of the eb target of the Agent Runway environment two. It is also the second segment of the Variables' SSM path."
  type        = string
  default     = "two-eb-amd64"
}

variable "solution_stack" {
  description = "The Elastic Beanstalk Docker platform of new and updated environments."
  type        = string
  default     = "64bit Amazon Linux 2023 v4.14.1 running Docker"
}

variable "amd64_instance_types" {
  description = "The amd64 instance types of the size tiers small, medium and large, in that order."
  type        = list(string)
  default     = ["t3.small", "t3.medium", "m7i.large"]

  validation {
    condition     = length(var.amd64_instance_types) == 3 && alltrue([for type in var.amd64_instance_types : !can(regex("^[a-z][0-9]+g[a-z]*\\.", type))])
    error_message = "Give three amd64 (not Graviton) instance types, one per size tier."
  }
}
