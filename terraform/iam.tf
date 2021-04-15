data "aws_iam_policy_document" "terraform_state_bucket" {
    statement {
        actions = ["s3:ListBucket"]
        resources = ["arn:aws:s3:::storybooks"]
    }

    statement {
        actions = ["s3:GetObject", "s3:PutObject"]
        resources = ["arn:aws:s3:::storybooks/state/storybooks"]
    }
}

data "aws_iam_policy_document" "terraform_state_locks" {
    statement {
        actions = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
        resources = ["arn:aws:dynamodb:us-east-1:$${AWS::AccountId}/table/storybooks"]
    }
}

data "aws_iam_policy_document" "combined_policies" {
    source_policy_documents = [
        data.aws_iam_policy_document.terraform_state_bucket.json,
        data.aws_iam_policy_document.terraform_state_locks.json
    ]
}

resource "aws_iam_policy" "policy" {
    name   = "s3_dynomodb_policy"
    policy = data.aws_iam_policy_document.combined_policies.json
}

output "aws_iam_policy_output" {
    value = data.aws_iam_policy_document.combined_policies.json
    description = "output of malformed policy"
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
    user = aws_iam_user.user.name
    policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_user" "user" {
    name = "storybooks"
}