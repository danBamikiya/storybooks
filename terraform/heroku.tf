provider "heroku" {
  email   = secrethub_secret.HEROKU_EMAIL.value
  api_key = secrethub_secret.HEROKU_API_KEY.value
}

# Create a new Heroku app
resource "heroku_app" "default" {
  name   = terraform.workspace == "staging" ? "${var.app_name}-${terraform.workspace}" : var.app_name
  region = "us"
  stack  = "container"
}

# Build code & release to the app
resource "heroku_build" "this" {
  app = heroku_app.this.name
  buildpacks = ["https://github.com/heroku/heroku-buildpack-nodejs"]

  source = {
    path = "."
  }
}

# Launch the app's web process by scaling-up
resource "heroku_formation" "this" {
  app         = heroku_app.this.name
  type        = "web"
  quantity    = 1
  size        = "Standard-1x"
  depends_on  = [heroku_build.this]

  provisioner "local-exec" {
    command = "bash ./scripts/health-check ${heroku_app.this.web_url}"
  }
}

output "web_url" {
  value = heroku_app.this.web_url
}


# Static IP ADDRESS
# resource "heroku_addon" "ip_address" {
#   app  = heroku_app.this.name
#   plan = "fixie-socks:grip"
# }

# Add a web-hook addon for the app
#resource "heroku_addon" "webhook" {
#  app  = heroku_app.this.id
#  plan = "deployhooks:http"
#
#  config = {
#    url = "http://google.com"
#  }
#}
