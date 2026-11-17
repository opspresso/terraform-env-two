data "terraform_remote_state" "domain" {
  backend = "s3"
  config = {
    region = "ap-northeast-2"
    bucket = "terraform-workshop-552292899126"
    key    = "backend/two/domain-two/terraform.tfstate"
  }
}
