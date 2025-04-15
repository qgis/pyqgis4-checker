# QGIS with Qt6 and PyQGIS 4 Checker

[![pipeline status](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/badges/main/pipeline.svg)](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/commits/main)  [![Latest Release](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/badges/release.svg)](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/releases)

This repository aims to provide developers with tools for the migration of QGIS from Qt5 to Qt6, including a version bump to QGIS 4. It contains 2 docker images:

- `qgis-qt6-unstable`: QGIS built against Qt6 with major drivers (including Oracle) and options based on [Fedora](https://fedoraproject.org/fr/) (a Linux distribution known to be eager to keep up with the latest package versions). This image is considered as unstable and not official. Its main goal is to provide a modern basis to run tests.
- `pyqgis4-checker`: the same Docker image but additionally shipping the tools to check your PyQGIS code, especially plugins.

## Requirements

- Docker >= 28
- network access to: docker.com, github.com, gitlab.com
- available disk space: ~10 Go

## QGIS with Qt6 (Fedora based)

### Build

```sh
docker buildx build --pull --rm -f qgis-qt6-unstable.dockerfile \
    --cache-from type=local,src=/tmp/docker-cache \
    --cache-to type=local,dest=/tmp/docker-cache,mode=max \
    --progress=plain \
    --build-arg QGIS_GIT_VERSION=master \
    -t qgis-qt6-unstable:latest .
```

### Run

Get into the container:

```sh
docker run -it --rm --name qgis-qt6 qgis-qt6-unstable:latest /bin/bash
```

To launch QGIS from the host, use the following command (requires a x11 server):

```sh
# authorize the docker user to x11
xhost +local:docker
# launch QGIS from inside the Docker and stream the display with x11 to your host
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -e LC_ALL=C.utf8 \
  -e LANG=C.utf8 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  qgis-qt6-unstable:latest \
  qgis
```

## PyQGIS4 Checker

Get your QGIS plugin ready for QGIS 4 using the migration script to check your code against PyQGIS 4 and PyQt6.

### Build

```sh
docker build --pull --rm -f 'Dockerfile' -t 'pyqgis4checker:latest' '.'
```

### Run it

Using the published image:

```sh
# print the help
docker run registry.gitlab.com/oslandia/qgis/pyqgis-4-checker/pyqgis-qt-checker:latest pyqt5_to_pyqt6.py --help
# on a folder on the host
docker run --rm -v "$(pwd):/home/pyqgisdev/" registry.gitlab.com/oslandia/qgis/pyqgis-4-checker/pyqgis-qt-checker:latest pyqt5_to_pyqt6.py --logfile /home/pyqgisdev/pyqt6_checker.log .
```

Locally, after build:

```sh
# print the QGIS version
docker run pyqgis4checker:latest qgis --version
# print the help
docker run pyqgis4checker:latest pyqt5_to_pyqt6.py --help
# on a folder on the host
docker run --rm -v "$(pwd):/home/pyqgisdev/" pyqgis4checker:latest pyqt5_to_pyqt6.py --logfile /home/pyqgisdev/pyqt6_checker.log .
```

### Publish

Image is supposed to be built and published through GitLab CI/CD :

- every commit on default branch = latest
- every git tag = tag

It's also possible to push the image directly from the local build:

1. First, authenticate to the container registry (a Personal Access Token is required):

    ```sh
    docker login registry.gitlab.com
    ```

1. Then build the image tagging with the registry URI:

    ```sh
    docker build --pull --rm -f 'Dockerfile' -t registry.gitlab.com/oslandia/qgis/pyqgis-4-checker/pyqgis-qt-checker:latest .
    ```

1. Push it:

    ```sh
    docker push registry.gitlab.com/oslandia/qgis/pyqgis-4-checker/pyqgis-qt-checker
    ```

## Contributing

### Lint

Install using pipx:

```sh
pipx install pre-commit
```

Run:

```sh
pre-commit install
```
