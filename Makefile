CURRENT_DATE := $(shell date +"%Y-%m-%d")
IMAGE := us-docker.pkg.dev/jarvice/images/app-converge:$(CURRENT_DATE)
all:
	podman build --jobs 0 --pull --rm -f "Dockerfile" -t $(IMAGE) "."

push: all
	podman push $(IMAGE)
