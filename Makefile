all:
	podman build --jobs 0 --pull --rm -f "Dockerfile" -t us-docker.pkg.dev/jarvice/images/app-converge:2024-03-14 "."

push: all
	podman push us-docker.pkg.dev/jarvice/images/app-converge:2024-03-14
