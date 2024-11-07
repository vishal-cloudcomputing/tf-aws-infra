resource "aws_iam_policy" "CSYE6225_Custome_Policy" {
  depends_on = [
    aws_s3_bucket.csye6225_bucket
  ]

  name = "WebAppPolicy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
          ],
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:s3:::${aws_s3_bucket.csye6225_bucket.bucket}",
            "arn:aws:s3:::${aws_s3_bucket.csye6225_bucket.bucket}/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role" "CSYE6225_S3_Role" {
  name = "CSYE6225_S3_Role"

  depends_on = [
    aws_s3_bucket.csye6225_bucket
  ]

  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    }
EOF

  tags = {
    "Name" = "csye6225_role"
  }
}

resource "aws_iam_role" "CSYE6225_EC2_Role" {
  name = "CSYE6225_EC2_Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.CSYE6225_EC2_Role.name
  policy_arn = aws_iam_policy.CSYE6225_Custome_Policy.arn
}

resource "aws_iam_role_policy_attachment" "policy-attach2" {
  role       = aws_iam_role.CSYE6225_EC2_Role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "CSYE6225-profile" {
  name = "iam-profile"
  role = aws_iam_role.CSYE6225_EC2_Role.name
}
