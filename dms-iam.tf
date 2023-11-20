# Role for DMS to access Secrets Manager
data "aws_iam_policy_document" "dms-secrets-manager-policy" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.creds["MariaDB"].arn,
      aws_secretsmanager_secret.creds["MySQL57"].arn
    ]
  }
}

data "aws_iam_policy_document" "dms-secrets-manager-trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["dms.eu-west-1.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "dms-secrets-manager-policy" {
  name        = "dms-secrets-manager-policy"
  description = "Policy for DMS to access Secrets Manager"
  policy      = data.aws_iam_policy_document.dms-secrets-manager-policy.json
}

resource "aws_iam_role" "DmsRole" {
  name               = "DmsRole"
  assume_role_policy = data.aws_iam_policy_document.dms-secrets-manager-trust.json
}

resource "aws_iam_role_policy_attachment" "dms-secrets-manager-policy" {
  role       = aws_iam_role.DmsRole.name
  policy_arn = aws_iam_policy.dms-secrets-manager-policy.arn
}

# Role for DMS to do things in the VPC
data "aws_iam_policy_document" "dms-vpc-trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["dms.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "dms-vpc-role" {
  name               = "dms-vpc-role"
  assume_role_policy = data.aws_iam_policy_document.dms-vpc-trust.json
}

resource "aws_iam_role_policy_attachment" "dms-vpc-policy" {
  role       = aws_iam_role.dms-vpc-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}
