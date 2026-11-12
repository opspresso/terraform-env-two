variable "region" {
  description = "The region of the VPC."
  type        = string
  default     = "ap-northeast-2"
}

variable "account_id" {
  description = "The account nalbam-two. The provider refuses credentials of any other account."
  type        = string
  default     = "552292899126"
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC. It does not overlap the eks-demo VPC of opspresso (10.10.0.0/16)."
  type        = string
  default     = "10.20.0.0/16"
}

variable "az_subnets" {
  description = "Subnet CIDR blocks by availability zone letter. Load balancers use the public subnets; instances use the private subnets, which reach the internet through one NAT gateway."
  type = map(object({
    public  = string
    private = string
  }))
  default = {
    a = { public = "10.20.0.0/20", private = "10.20.64.0/20" }
    c = { public = "10.20.16.0/20", private = "10.20.80.0/20" }
  }

  validation {
    condition     = length(var.az_subnets) >= 2
    error_message = "An application load balancer needs subnets in two or more availability zones."
  }
}

variable "nat_az" {
  description = "The availability zone letter of the single NAT gateway."
  type        = string
  default     = "a"

  validation {
    condition     = contains(keys(var.az_subnets), var.nat_az)
    error_message = "nat_az must be a key of az_subnets."
  }
}
