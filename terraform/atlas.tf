provider "mongodbatlas" {
  public_key  = data.secrethub_secret.MONGODBATLAS_PUBLIC_KEY.value
  private_key = data.secrethub_secret.MONGODBATLAS_PRIVATE_KEY.value
}

# cluster
data "mongodbatlas_cluster" "mongo_user" {
  project_id = data.secrethub_secret.ATLAS_PROJECT_ID.value
  name       = var.app_name
}

# db user
resource "mongodbatlas_database_user" "mongo_user" {
  username           = "storybooks-user-${terraform.workspace}"
  password           = secrethub_secret.ATLAS_USER_PASSWORD.value
  project_id         = data.secrethub_secret.ATLAS_PROJECT_ID.value
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "storybooks"
  }
}

# ip accesslist
resource "mongodbatlas_project_ip_access_list" "mongo_user" {
  project_id = data.secrethub_secret.ATLAS_PROJECT_ID.value
  ip_address = "0.0.0.0"
}