resource "aws_s3_bucket" "s3-log" {
  bucket = "web-log-by-biata"
  versioning {
    enabled = true
  }
  tags = {
    Name  = "log bucket"
  }
}