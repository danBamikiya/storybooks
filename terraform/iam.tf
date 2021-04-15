data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "s3_policy" {
    name        = "terraform-state-s3-access"
    path        = "/"
    description = "Access to the terraform state bucket"
    policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "${aws_s3_bucket.terraform_state.arn}"
        },
        {
            "Effect": "Allow",
            "Action": ["s3:GetObject", "s3:PutObject"],
            "Resource": "${aws_s3_bucket.terraform_state.arn}/*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "dynamodb_policy" {
    name        = "terraform-state-dynamodb-access"
    path        = "/"
    description = "Access to the terraform state lock"
    policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"],
            "Resource": "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current.account_id}:table/storybooks"
        }
    ]
}
EOF
}

resource "aws_iam_user" "user" {
    name = "storybooks"
}

resource "aws_iam_user_policy_attachment" "attach_s3_policy" {
    user = aws_iam_user.user.name
    policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_user_policy_attachment" "attach_dynamodb_policy" {
    user = aws_iam_user.user.name
    policy_arn = aws_iam_policy.dynamodb_policy.arn
}