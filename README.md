# PyQGIS 4 Checker

## Build

```sh
docker build --pull --rm -f 'Dockerfile' -t 'pyqgis4checker:latest' '.'
```

## Run it

```sh
docker run pyqgis4checker:latest pyqt5_to_pyqt6.py --help
```
