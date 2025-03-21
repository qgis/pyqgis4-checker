# PyQGIS 4 Checker

[![pipeline status](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/badges/master/pipeline.svg)](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/commits/master)  [![Latest Release](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/badges/release.svg)](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/releases)

Get your QGIS plugin ready for Qt6!

## Build

```sh
docker build --pull --rm -f 'Dockerfile' -t 'pyqgis4checker:latest' '.'
```

## Run it

Using the published image:

```sh
# print the help
docker run registry.gitlab.com/oslandia/qgis/pyqgis-4-checker/pyqgis-qt-checker:latest pyqt5_to_pyqt6.py --help
# on a folder on the host
docker run --rm -v "$(pwd):/home/pyqgisdev/" registry.gitlab.com/oslandia/qgis/pyqgis-4-checker/pyqgis-qt-checker:latest pyqt5_to_pyqt6.py --logfile /home/pyqgisdev/pyqt6_checker.log .
```

Locally, after build:

```sh
# print the help
docker run pyqgis4checker:latest pyqt5_to_pyqt6.py --help
# on a folder on the host
docker run --rm -v "$(pwd):/home/pyqgisdev/" pyqgis4checker:latest pyqt5_to_pyqt6.py --logfile /home/pyqgisdev/pyqt6_checker.log .
```

## Publish

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

## Lint

Install using pipx:

```sh
pipx install pre-commit
```

Run:

```sh
pre-commit install
```
