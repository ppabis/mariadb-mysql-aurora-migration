resource "aws_s3_bucket" "dms-reports" {
  bucket = "dms-reports-i2301203231"
}

resource "aws_s3_bucket_policy" "dms-reports" {
  bucket = aws_s3_bucket.dms-reports.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = aws_iam_role.dms-premigration-role.arn }
      Action    = "s3:PutObject"
      Resource  = "${aws_s3_bucket.dms-reports.arn}/*"
    }]
  })
}

resource "aws_iam_role" "dms-premigration-role" {
  name = "dms-premigration-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "dms.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# For convenience. Bucket name must start with `dms-`. Otherwise provide your
# own policy.
resource "aws_iam_role_policy_attachment" "dms-premigration-policy" {
  role       = aws_iam_role.dms-premigration-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
}
