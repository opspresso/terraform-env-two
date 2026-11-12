terraform {
  required_version = "1.17.1"

  backend "s3" {
    region       = "ap-northeast-2"
    bucket       = "terraform-workshop-552292899126"
    key          = "backend/two/runway-target-two/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
  }
}

provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]

  default_tags {
    tags = local.tags
  }
}
