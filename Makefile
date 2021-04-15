PROJECT_ID=storiesswipe
CONTAINER_NAME=storybooks-api

run-local:
	docker-compose up -d
	docker-compose logs -f

teardown-local:
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
		-var-file="./environments/common.tfvars"

###


GITHUB_SHA?=latest
APP_NAME=
LOCAL_TAG=storybooks-app:$(GITHUB_SHA)
REMOTE_TAG=$(DOCKERHUB_USERNAME)/$(LOCAL_TAG)

set-app-name:
ifdef ENV=staging
	APP_NAME=storybooks-staging
else
	APP_NAME=storybooks
endif

check-app-name:
ifndef APP_NAME
	$(error Please set APP_NAME)
endif

HEROKU_REMOTE_TAG=registry.heroku.com/$(APP_NAME)


build:
	docker build -t $(LOCAL_TAG) .

push:
	echo "tagging docker image..."
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	echo "pushing image to dockerhub..."
	docker push $(REMOTE_TAG)

heroku-push: check-env set-app-name
	echo "pulling new container image..."
	docker pull $(REMOTE_TAG)
	echo "removing old container image"
	-docker rmi $(docker inspect $(HEROKU_REMOTE_TAG) --format={{.Id}})
	echo "tagging new image..."
	docker tag $(REMOTE_TAG) $(HEROKU_REMOTE_TAG)
	echo "pushing new image to heroku..."
	docker push $(HEROKU_REMOTE_TAG)

deploy: check-app-name
	echo "releasing new image..."
	curl --fail \
		-X PATCH "https://api.heroku.com/apps/$(APP_NAME)/formation" \
		-H 'Content-Type:application/json' \
		-H 'Accept:application/vnd.heroku+json; version=3.docker-releases' \
		-H "Authorization:Bearer $(HEROKU_API_KEY)" \
		-d '{
			"updates": [
				{
					"type": "web",
					"docker_image": "'$(docker inspect $(HEROKU_REMOTE_TAG) --format={{.Id}})'"
				}
			]
		}' && \
		@sh -c "./scripts/health-check https://$(APP_NAME).herokuapp.com/"