terraform {
    backend "s3" {
        bucket = "storiesswipe-terraform"
        key = "/state/${terraform.workspace}/storybooks"
        region = var.aws_region

        dynamodb_table = "storiesswipe-terraform"
        encrypt        = true
    }

    required_providers {
        secrethub = {
            version = ">= 1.2.0"
        }

        heroku = {
            version = "~> 4"
        }

        mongodbatlas = {
            version = "~> 0.6"
        }

        aws = {
            version = "~> 3.27"
        }
    }
}