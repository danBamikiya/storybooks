provider "secrethub" {}

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