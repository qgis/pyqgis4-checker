# QGIS with Qt6 and PyQGIS 4 Checker

[![pipeline status](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/badges/master/pipeline.svg)](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/commits/master)  [![Latest Release](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/badges/release.svg)](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/releases)

## Intermediary image: QGIS with Qt6 (Fedora based)

## Create a Docker Image for QGIS Qt6

Everything described in this procedure must be performed in the [official QGIS repo](https://github.com/qgis/QGIS).

:warning: Before proceeding, I had to remove `.ci` from `.dockerignore` in my QGIS repository; otherwise, it wouldn't be copied, and the script `/root/QGIS/.docker/docker-qgis-build.sh` requires it.

Named `qgis-qt6.dockerfile` and placed in `QGIS/.docker`

```sh
docker build -f .docker/qgis-qt6.dockerfile -t qgis-master-qt6 .
```

The build is successful. You can connect to the image using:

```sh
docker run -it --rm --name qgis-master-qt6 qgis-master-qt6:latest /bin/bash
```

To launch QGIS, use the following command:

```sh
docker run --rm \
    -i -t \
    -v ${HOME}:/home/${USER} \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=${DISPLAY} \
    --net=host \
    -e LD_LIBRARY_PATH=/root/QGIS/build/output/lib \
    qgis-qt6 /root/QGIS/build/output/bin/qgis
```

## PyQGIS4 Checker

Get your QGIS plugin ready for QGIS 4 (QGIS based on Qt6)!

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
