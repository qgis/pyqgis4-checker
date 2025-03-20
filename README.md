# PyQGIS 4 Checker

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

```sh
sudo apt install pipx
pipx install pre-commit
```

```sh
pre-commit install
```
