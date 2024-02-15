all: check-env
	podman build --jobs 0 --pull --rm -f "Dockerfile" --build-arg RLM_LICENSE=$(RLM_LICENSE) -t us-docker.pkg.dev/jarvice/images/app-converge:2024-02-13 "."

check-env:
ifndef RLM_LICENSE
	$(error RLM_LICENSE is undefined)
endif

push: all
	podman push us-docker.pkg.dev/jarvice/images/app-converge:2024-02-13
