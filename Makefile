
.PHONY: build

build:
	@./_k8s/scripts/build.sh

deploy:
	@./_k8s/scripts/deploy.sh $(ENVIRONMENT)
