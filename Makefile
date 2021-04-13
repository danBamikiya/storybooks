PROJECT_ID=storiesswipe
CONTAINER_NAME=storybooks-api

run-local:
	docker-compose up -d
	docker-compose logs -f

stop-run-local:
	docker-compose down -v


stop-local:
	docker container stop $(CONTAINER_NAME)
	docker container rm $(CONTAINER_NAME)

###

# create-tf-backend-bucket:
# 	aws s3 mb s3://$(PROJECT_ID)-terraform --region us-east-1

###

ENV?=staging

###

check-env:
ifndef ENV
	$(error Please set ENV=[staging|prod])
endif

set-gh-secret:
	gh secret set $(1)

# This cannot be indented or else make will include spaces in front of secret
define get-secret
$(shell gcloud secrets versions access latest --secret=$(1) --project=$(PROJECT_ID))
endef

###

terraform-create-workspace: check-env
	cd terraform && \
		terraform workspace new $(ENV)

terraform-init: check-env
	cd terraform && \
		terraform workspace select $(ENV) && \
		terraform init

TF_ACTION?=plan
terraform-action: check-env
	@cd terraform && \
		terraform workspace select $(ENV) && \
		terraform $(TF_ACTION) \
		-var-file="./environments/common.tfvars" \
		-var-file="./environments/$(ENV)/config.tfvars" \
		-var="mongodbatlas_private_key=$(call get-secret,atlas_private_key)" \
		-var="atlas_user_password=$(call get-secret,atlas_user_password_$(ENV))"

###

OAUTH_CLIENT_ID=630937217477-dc6vd2bcovn4siq1cqk9dfu38h3tahp2.apps.googleusercontent.com

GITHUB_SHA?=latest
LOCAL_TAG=storybooks-app:$(GITHUB_SHA)
REMOTE_TAG=$(DOCKERHUB_USERNAME)/$(LOCAL_TAG)

DB_NAME=storybooks

build:
	docker build -t $(LOCAL_TAG) .

push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)
###


deploy:	check-env
		@echo "pulling new container image..."
		$(MAKE) docker pull $(REMOTE_TAG)
		@echo "removing old container..."
		-$(MAKE) docker container stop $(CONTAINER_NAME)
		-$(MAKE) docker container rm $(CONTAINER_NAME)
		@echo "starting new container..."
		@$(MAKE) docker run -d --name=$(CONTAINER_NAME) \
		--restart=unless-stopped \
		-p 80:7070 \
		-e PORT=7070 \
		-e \"MONGO_URI=mongodb+srv://storybooks-user-$(ENV):$(call get-secret,ATLAS_USER_PASSWORD_$(ENV))@storybooks-$(ENV).cwmqs.mongodb.net/$(DB_NAME)?retryWrites=true&w=majority\" \
		-e GOOGLE_CLIENT_ID=$(OAUTH_CLIENT_ID) \
		-e GOOGLE_CLIENT_SECRET=$(call get-secret,OAUTH_CLIENT_SECRET) \
		$(REMOTE_TAG)