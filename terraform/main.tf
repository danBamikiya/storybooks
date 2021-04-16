terraform {
    backend "s3" {
        bucket = "storybooks-terraform"
        key = "state/storybooks"
        region = "us-east-1"

        dynamodb_table = "storybooks-terraform"
        encrypt        = true
    }

    required_providers {
        secrethub = {
            source = "secrethub/secrethub"
            version = ">= 1.2.0"
        }

        heroku = {
            source = "heroku/heroku"
            version = "~> 4"
        }

        mongodbatlas = {
            source = "mongodb/mongodbatlas"
            version = "~> 0.8.2"
        }

        aws = {
            source = "hashicorp/aws"
            version = "~> 3.27"
        }
    }
}