resource "aws_s3_bucket" "todo_app" {
  bucket        = var.app_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "todo_app_ownership_controls" {
  bucket = aws_s3_bucket.todo_app.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "todo_s3_acl" {

  depends_on = [aws_s3_bucket_ownership_controls.todo_app_ownership_controls]

  bucket = aws_s3_bucket.todo_app.id
  acl    = "private"
}
