provider "secrethub" {}

### HEROKU
data "secrethub_secret" "HEROKU_EMAIL" {
  path = "danBamikiya/storybooks/HEROKU_EMAIL"
}

data "secrethub_secret" "HEROKU_API_KEY" {
  path = "danBamikiya/storybooks/HEROKU_API_KEY"
}

### ATLAS
resource "secrethub_secret" "atlas_user_password_staging" {
  path = "danBamikiya/storybooks/atlas_user_password_staging"

  generate {
    length      = 22
  }
}

resource "secrethub_secret" "atlas_user_password_prod" {
  path = "danBamikiya/storybooks/atlas_user_password_prod"

  generate {
    length      = 22
  }
}

data "secrethub_secret" "atlas_project_id" {
  path = "danBamikiya/storybooks/atlas_project_id"
}

data "secrethub_secret" "mongodbatlas_public_key" {
  path = "danBamikiya/storybooks/mongodbatlas_public_key"
}

data "secrethub_secret" "mongodbatlas_private_key" {
  path = "danBamikiya/storybooks/mongodbatlas_private_key"
}

### GOOGLE OAUTH
data "secrethub_secret" "oauth_client_id" {
  path = "danBamikiya/storybooks/oauth_client_id"
}

data "secrethub_secret" "oauth_client_secret" {
  path = "danBamikiya/storybooks/oauth_client_secret"
}

### EXPRESS-SESSION
data "secrethub_secret" "express_session_secret" {
  path = "danBamikiya/storybooks/express_session_secret"
}