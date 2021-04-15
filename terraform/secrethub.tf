provider "secrethub" {}

### HEROKU
data "secrethub_secret" "HEROKU_EMAIL" {
  path = "danBamikiya/storybooks/HEROKU_EMAIL"
}

data "secrethub_secret" "HEROKU_API_KEY" {
  path = "danBamikiya/storybooks/HEROKU_API_KEY"
}

### ATLAS
resource "secrethub_secret" "ATLAS_USER_PASSWORD_staging" {
  path = "danBamikiya/storybooks/ATLAS_USER_PASSWORD_staging"

  generate {
    length      = 22
  }
}

resource "secrethub_secret" "ATLAS_USER_PASSWORD_prod" {
  path = "danBamikiya/storybooks/ATLAS_USER_PASSWORD_prod"

  generate {
    length      = 22
  }
}

data "secrethub_secret" "ATLAS_PROJECT_ID" {
  path = "danBamikiya/storybooks/ATLAS_PROJECT_ID"
}

data "secrethub_secret" "MONGODBATLAS_PUBLIC_KEY" {
  path = "danBamikiya/storybooks/MONGODBATLAS_PUBLIC_KEY"
}

data "secrethub_secret" "MONGODBATLAS_PRIVATE_KEY" {
  path = "danBamikiya/storybooks/MONGODBATLAS_PRIVATE_KEY"
}

### GOOGLE OAUTH
data "secrethub_secret" "OAUTH_CLIENT_ID" {
  path = "danBamikiya/storybooks/OAUTH_CLIENT_ID"
}

data "secrethub_secret" "OAUTH_CLIENT_SECRET" {
  path = "danBamikiya/storybooks/OAUTH_CLIENT_SECRET"
}

### EXPRESS-SESSION
data "secrethub_secret" "EXPRESS_SESSION_SECRET" {
  path = "danBamikiya/storybooks/EXPRESS_SESSION_SECRET"
}