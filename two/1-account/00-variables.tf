variable "region" {
  description = "The region of the provider and of the EBS encryption default. EBS encryption by default is set per region."
  type        = string
  default     = "ap-northeast-2"
}

variable "account_id" {
  description = "The account nalbam-two. The provider refuses credentials of any other account."
  type        = string
  default     = "552292899126"
}

variable "account_alias" {
  description = "The IAM account alias: the name the sign-in page and the console show instead of the account ID."
  type        = string
  default     = "nalbam-two"
}
