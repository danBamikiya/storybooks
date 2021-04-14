provider "heroku" {
  email   = data.secrethub_secret.HEROKU_EMAIL.value
  api_key = data.secrethub_secret.HEROKU_API_KEY.value
}

# Create a new Heroku app
resource "heroku_app" "default" {
  name   = terraform.workspace == "staging" ? "${var.app_name}-${terraform.workspace}" : var.app_name
  region = "us"
  stack  = "container"
}

# Define variables
resource "heroku_config" "secrets" {
  vars = {
    PORT = 7070
  }

  sensitive_vars = {
    EXPRESS_SESSION_SECRET = "data.secrethub_secret.express_session_secret.value"
    GOOGLE_CLIENT_SECRET = data.secrethub_secret.oauth_client_secret.value
    GOOGLE_CLIENT_ID = data.secrethub_secret.oauth_client_id.value
    MONGO_URI = "mongodb+srv://storybooks-user-$(terraform.workspace):$(secrethub_secret.atlas_user_password_$(terraform.workspace).value)@storybooks-$(terraform.workspace).cwmqs.mongodb.net/$(var.db_name)?retryWrites=true&w=majority"
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