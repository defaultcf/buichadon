resource "aws_s3_bucket" "main" {
  bucket = local.files_domain
}

#resource "aws_s3_bucket_public_access_block" "main" {
#  bucket = aws_s3_bucket.main.id
#
#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#}

data "aws_iam_policy_document" "main" {
  version = "2012-10-17"
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.main.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.files.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json
}

resource "aws_iam_user" "s3_rw" {
  name = "${local.project}-s3-rw"
}

data "aws_iam_policy" "s3_rw" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "s3_rw" {
  user       = aws_iam_user.s3_rw.name
  policy_arn = data.aws_iam_policy.s3_rw.arn
}
