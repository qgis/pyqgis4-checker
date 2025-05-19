# QGIS with Qt6 and PyQGIS 4 Checker

[![📦 Build & 🚀 Release](https://github.com/qgis/pyqgis4-checker/actions/workflows/build_package_release.yml/badge.svg)](https://github.com/qgis/pyqgis4-checker/actions/workflows/build_package_release.yml) [![pre-commit.ci status](https://results.pre-commit.ci/badge/github/qgis/pyqgis4-checker/main.svg)](https://results.pre-commit.ci/latest/github/qgis/pyqgis4-checker/main)

This repository aims to provide developers with tools for the migration of QGIS from Qt5 to Qt6, including a version bump to QGIS 4. It contains 2 docker images:

- `qgis-qt6-unstable`: QGIS built against Qt6 with major drivers (including Oracle) and options based on [Fedora](https://fedoraproject.org/fr/) (a Linux distribution known to be eager to keep up with the latest package versions). This image is considered as unstable and not official. Its main goal is to provide a modern basis to run tests.
- `pyqgis4-checker`: the same Docker image but additionally shipping the tools to check your PyQGIS code, especially plugins.

## Requirements

- Docker >= 28
- network access to: docker.com, github.com, gitlab.com
- available disk space: ~10 Go

## QGIS with Qt6 (Fedora based)

Test QGIS Desktop with Qt6 running within a Docker container.

### Tagging Strategy

| Event                   | Docker tag applied              | Description                                                      |
| :---------------------- | :-----------------------------: | :--------------------------------------------------------------- |
| Commit on `main` branch | `main`                          | Development image, always up to date with QGIS main branch.      |
| Git tag (e.g. `3.40.5`) | `3.40.5`                        | Image matching an official QGIS release.                         |
| Latest published tag    | `latest`                        | Always synchronized with the most recently published tagged version.     |
| Build cache export      | `cache`                         | Special tag used to store Docker build cache layers. Not for direct use. |

### Run published image

Get into the container:

```sh
docker run -it --pull --rm ghcr.io/qgis/qgis-qt6-unstable:main /usr/bin/bash
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
  ghcr.io/qgis/qgis-qt6-unstable:main \
  qgis
```

### Build locally

Classic:

```sh
docker build --pull --rm -f qgis-qt6-unstable.dockerfile \
    --progress=plain \
    --build-arg QGIS_GIT_VERSION=master \
    -t qgis-qt6-unstable:local .
```

With BuildKit and advanced cache:

```sh
docker buildx create --name qgisbuilder --driver docker-container --use
```

```sh
docker buildx build --pull --rm --file qgis-qt6-unstable.dockerfile \
    --build-arg CCACHE_DIR=/root/.ccache \
    --build-arg QGIS_GIT_VERSION=master \
    --cache-from type=local,src=.cache/docker/qgis/ \
    --cache-from type=registry,ref=ghcr.io/qgis/qgis-qt6-unstable:cache \
    --cache-to type=local,dest=.cache/docker/qgis/,mode=max \
    --load \
    --platform linux/amd64 \
    -t qgis-qt6-unstable:local .
```

> [!NOTE]
> This command store a local cache under .cache/docker/qgis/. If you need to save disk space, clen up this folder. Alternatively, you can set it to a temporary folder i.e. `/tmp/docker/cache`.

#### Build only the RUN stage

It's also possible to reuse the build cache directly local and remote, saving a lot of time:

```sh
docker buildx build --pull --rm --file qgis-qt6-unstable.dockerfile \
  --target stage-run \
  --build-arg BASE_RUN_IMAGE=ghcr.io/qgis/qgis-qt6-unstable:main \
  --cache-from type=local,src=.cache/docker/qgis/ \
  --cache-from type=registry,ref=ghcr.io/qgis/qgis-qt6-unstable:cache \
  --cache-to type=local,dest=.cache/docker/qgis/,mode=max \
  --load \
  --platform linux/amd64 \
  -t qgis-qt6-unstable:local .
```

### Run local image

Get into the container:

```sh
docker run -it --rm --name qgis-qt6 qgis-qt6-unstable:local /bin/bash
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
  qgis-qt6-unstable:main \
  qgis
```

## PyQGIS4 Checker

Get your QGIS plugin ready for QGIS 4 using the migration script to check your code against PyQGIS 4 and PyQt6.

### Run the published image

```sh
# print the help
docker run --rm --pull ghcr.io/qgis/pyqgis4-checker:main pyqt5_to_pyqt6.py --help
# on a folder on the host
docker run --rm --platform linux/amd64 -v "$(pwd):/home/pyqgisdev/" ghcr.io/qgis/pyqgis4-checker:main pyqt5_to_pyqt6.py --logfile /home/pyqgisdev/pyqt6_checker.log .
```

### Build locally

```sh
docker buildx build --pull --rm --file pyqgis4-checker.dockerfile \
  --cache-from type=local,src=.cache/docker/qgis/ \
  --cache-from type=registry,ref=ghcr.io/qgis/pyqgis4-checker:cache \
  --cache-to type=local,dest=.cache/docker/qgis/,mode=max \
  --load \
  --progress plain \
  --tag pyqgis4-checker:local .
```

### Run local image

```sh
# print the username
docker run pyqgis4-checker:local whoami
# print the QGIS version
docker run pyqgis4-checker:local qgis --version
# print the Qt version shipped from PyQGIS
docker run pyqgis4-checker:local python3 -c "from qgis.PyQt.QtCore import QT_VERSION_STR;print(f'Qt {QT_VERSION_STR}')"
# print migration script the help
docker run pyqgis4-checker:local pyqt5_to_pyqt6.py --help
# on a folder on the host
docker run -v "$(pwd):/home/pyqgisdev/" pyqgis4-checker:local pyqt5_to_pyqt6.py --logfile /home/pyqgisdev/pyqt6_checker.log .
```

### Publish

Images are supposed to be built and published through GitHub Actions (see [Tagging strategy](#tagging-strategy)):

It's also possible to push the image directly from the local build:

1. First, authenticate to the container registry (a Personal Access Token is required):

    ```sh
    docker login ghcr.github.io
    ```

1. Then build the image tagging with the registry URI:

    ```sh
    docker build --pull --rm -f 'Dockerfile' -t docker pull ghcr.io/qgis/pyqgis4-checker:main .
    ```

1. Push it:

    ```sh
    docker push docker pull ghcr.io/qgis/pyqgis4-checker:main
    ```

## Contributing

### Lint

Install using [pipx](https://pipx.pypa.io/stable/installation/):

```sh
pipx install pre-commit
```

Run:

```sh
pre-commit install
```
