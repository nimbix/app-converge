# APP-CONVERGE

## Installation

This repo contains *some* files needed to build the converge app.
The end user needs to acquire the converge.tar.bz2 file and place
the file into the same directory as the `Dockerfile` file. The
image can then be build by running `make` if `podman` is installed.
`docker` can be used instead:

```bash
DOCKER_BUILDKIT=1 docker build --pull --rm -f "Dockerfile" -t $(IMAGE) "."
```

## Licensing

In order to use the software, the user must define the variable
`RLM_LICENSE_SERVER` in their JARVICE variables.
