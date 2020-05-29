
.PHONY: build

build:
	@./_deploy/scripts/build.sh

deploy:
	@./_deploy/scripts/deploy.sh $(ENVIRONMENT)
