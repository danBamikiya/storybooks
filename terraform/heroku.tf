provider "heroku" {
  email   = data.secrethub_secret.HEROKU_EMAIL.value
  api_key = data.secrethub_secret.HEROKU_API_KEY.value
}

# Create a new Heroku app
resource "heroku_app" "default" {
    name   = "storybooks${terraform.workspace == "prod" ? "" : "-${terraform.workspace}"}"
    region = "us"
    stack  = "container"
}

# Define variables
resource "heroku_config" "secrets" {
  vars = {
    PORT = 7070
  }

  sensitive_vars = {
    EXPRESS_SESSION_SECRET = "data.secrethub_secret.EXPRESS_SESSION_SECRET.value"
    GOOGLE_CLIENT_SECRET = data.secrethub_secret.OAUTH_CLIENT_SECRET.value
    GOOGLE_CLIENT_ID = data.secrethub_secret.OAUTH_CLIENT_ID.value
    MONGO_URI = "mongodb+srv://storybooks-user-${terraform.workspace}:${secrethub_secret.ATLAS_USER_PASSWORD.value}@storybooks.cwmqs.mongodb.net/${var.db_name}?retryWrites=true&w=majority"
  }
}

# Associate variables to the app
resource "heroku_app_config_association" "variables" {
  app_id = heroku_app.default.id

  vars = heroku_config.secrets.vars
  sensitive_vars = heroku_config.secrets.sensitive_vars
}


# Static IP ADDRESS
# resource "heroku_addon" "ip_address" {
#   app  = heroku_app.this.name
#   plan = "fixie-socks:grip"
# }