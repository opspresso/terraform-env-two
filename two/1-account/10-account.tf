resource "aws_iam_account_alias" "this" {
  account_alias = var.account_alias
}

# No bucket of the account may be public. The Agent Runway eb target (two/8-runway-target) serves apps through load
# balancers and keeps its source bundles in a private bucket, so it needs no public bucket.
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# New EBS volumes in the region, such as the root volumes of Elastic Beanstalk instances, are encrypted with the AWS
# managed key aws/ebs. Existing volumes stay as they are.
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}
