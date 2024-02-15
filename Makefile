
all:
	podman build --jobs 0 --pull --rm -f "Dockerfile" --build-arg RLM_LICENSE=$(RLM_LICENSE) -t us-docker.pkg.dev/jarvice/images/app-converge:2024-02-13 "."

push: all
	podman push us-docker.pkg.dev/jarvice/images/app-converge:2024-02-13
