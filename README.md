# PyQGIS 4 Checker

[![pipeline status](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/badges/master/pipeline.svg)](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/commits/master)  [![Latest Release](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/badges/release.svg)](https://gitlab.com/Oslandia/qgis/pyqgis-4-checker/-/releases) 

## Build

```sh
docker build --pull --rm -f 'Dockerfile' -t 'pyqgis4checker:latest' '.'
```

## Run it

Using the published image:

```sh
docker run registry.gitlab.com/oslandia/qgis/pyqgis-4-checker/pyqgis-qt-checker:latest pyqt5_to_pyqt6.py --help
```

Locally, after build:

```sh
docker run pyqgis4checker:latest pyqt5_to_pyqt6.py --help
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
