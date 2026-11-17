# Versions of the state objects. A state overwritten by a failed apply or deleted by mistake can be restored only from
# an earlier version.
resource "aws_s3_bucket_versioning" "state" {
  bucket = local.state_bucket

  versioning_configuration {
    status = "Enabled"
  }
}
