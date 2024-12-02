resource "aws_iam_policy" "CSYE6225_Custom_Policy" {
  name        = "CSYE6225_Custom_Policy"
  description = "Custom IAM Policy for CSYE6225 Web Application"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2Actions"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::your-s3-bucket-name/*"
      },
      {
        Sid    = "AllowSecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowKMSUsage"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowKMSKeyManagement"
        Effect = "Allow"
        Action = [
          "kms:CreateKey",
          "kms:PutKeyPolicy",
          "kms:EnableKeyRotation",
          "kms:DescribeKey",
          "kms:ListKeys"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "CSYE6225_EC2_Role" {
  name = "WebAppRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "web_app_policy_attachment" {
  role       = aws_iam_role.CSYE6225_EC2_Role.name
  policy_arn = aws_iam_policy.CSYE6225_Custom_Policy.arn
}

resource "aws_iam_instance_profile" "CSYE6225-profile" {
  name = "WebAppProfile"
  role = aws_iam_role.CSYE6225_EC2_Role.name
}
