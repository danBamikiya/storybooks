PROJECT_ID=storybooks
CONTAINER_NAME=storybooks-api

run-local:
	docker-compose up -d
	docker-compose logs -f

teardown-local:
	docker-compose down -v

RM=
stop-local:
	docker container stop $(CONTAINER_NAME)
	$(if $(RM),docker container rm $(CONTAINER_NAME))

###


ENV?=staging

check-env:
ifndef ENV
	$(error Please set ENV=[staging|prod])
endif


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
HEROKU_REMOTE_TAG=registry.heroku.com/$(APP_NAME)

check-app-name:
ifndef APP_NAME
	$(error Please set APP_NAME)
endif


build:
	docker build --rm -t $(LOCAL_TAG) .

push:
	echo "tagging docker image..."
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	echo "pushing image to dockerhub..."
	docker push $(REMOTE_TAG)

heroku-push: check-app-name
	echo "pulling new container image..."
	docker pull $(REMOTE_TAG)
	echo "removing old container image"
	-docker rmi $(HEROKU_REMOTE_TAG)
	echo "tagging new image..."
	docker tag $(REMOTE_TAG) $(HEROKU_REMOTE_TAG)
	echo "pushing new image to heroku..."
	docker push $(HEROKU_REMOTE_TAG)


IMAGE_ID=`docker inspect $(HEROKU_REMOTE_TAG) --format={{.Id}}`

deploy: check-app-name
	echo "releasing new image..."
	@curl --write-out '%{http_code}' --fail --silent --output /dev/null \
		-X PATCH https://api.heroku.com/apps/$(APP_NAME)/formation \
		-H 'Content-Type:application/json' \
		-H 'Accept:application/vnd.heroku+json; version=3.docker-releases' \
		-H "Authorization:Bearer $(HEROKU_API_KEY)" \
		-d '{"updates": [{"type": "web","docker_image": "$(IMAGE_ID)"}]}'

run-deploy: check-app-name
	@$(MAKE) deploy IMAGE_ID=$(IMAGE_ID)

check-app-health: check-app-name
	chmod u+r+x ./scripts/health-check
	@sh -c "./scripts/health-check https://$(APP_NAME).herokuapp.com/"
