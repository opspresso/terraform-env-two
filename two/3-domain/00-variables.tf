variable "region" {
  description = "The region of the provider. Route53 is global."
  type        = string
  default     = "ap-northeast-2"
}

variable "account_id" {
  description = "The account nalbam-two. The provider refuses credentials of any other account."
  type        = string
  default     = "552292899126"
}

variable "domain" {
  description = "The public zone of the account. The Agent Runway eb target two-eb-amd64 uses it as its app domain."
  type        = string
  default     = "two.rovr.dev"
}
