provider "mongodbatlas" {
  public_key  = data.secrethub_secret.MONGODBATLAS_PUBLIC_KEY.value
  private_key = data.secrethub_secret.MONGODBATLAS_PRIVATE_KEY.value
}

# cluster
resource "mongodbatlas_cluster" "mongo" {
  project_id = data.secrethub_secret.ATLAS_PROJECT_ID.value
  name       = "${var.app_name}-${terraform.workspace}"
  num_shards = 1

  replication_factor              = 3
  provider_backup_enabled         = true
  auto_scaling_disk_gb_enabled    = true
  mongo_db_major_version          = "3.6"

  //Provider Settings "block"
  provider_name                   = "AWS"
  disk_size_gb                    = 10
  provider_instance_size_name     = "M10"
  provider_region_name            = "US_EAST_1"
}

# db user
resource "mongodbatlas_database_user" "mongo_user" {
  username           = "storybooks-user-${terraform.workspace}"
  password           = secrethub_secret.ATLAS_USER_PASSWORD_${terraform.workspace}.value
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