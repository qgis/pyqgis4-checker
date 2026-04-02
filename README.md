# PyQGIS 4 Checker

[![📦 Build & 🚀 Release](https://github.com/qgis/pyqgis4-checker/actions/workflows/build_package_release.yml/badge.svg)](https://github.com/qgis/pyqgis4-checker/actions/workflows/build_package_release.yml) [![pre-commit.ci status](https://results.pre-commit.ci/badge/github/qgis/pyqgis4-checker/main.svg)](https://results.pre-commit.ci/latest/github/qgis/pyqgis4-checker/main)

Tools to check and migrate QGIS plugins from PyQt5 to PyQt6 / QGIS 4.

> [!NOTE]
> Now that QGIS 4 is officially released, the project has moved on.

To run the checker, choose the way that fits your setup:

- [Docker Ubuntu](#docker---ubuntu): CI/CD, or no local QGIS install
- [Docker Fedora](#docker---fedora-advanced): you need recent deps (Qt, GDAL) or specific build options (Oracle, SFCGAL...)

## Docker - Ubuntu

Based on Ubuntu 25.10 with QGIS installed from the [official QGIS repository](https://qgis.org/resources/installation-guide/).

### Requirements

- Docker >= 28
- Available disk space: ~3 GB

### Use it locally to check a plugin

#### Dry run (check only, no modification)

> List all the detected incompatibilities in a log file without modifying the code. The script will exit with code 0 even if some incompatibilities are spotted.

```sh
docker run --rm --pull always \
  --user $(id -u):$(id -g) \
  --workdir /workspace/ \
  -v "$(pwd):/workspace/" \
  ghcr.io/qgis/pyqgis4-checker:main-ubuntu \
  pyqt5_to_pyqt6.py --dry_run --logfile /workspace/pyqt6_checker.log .
```

#### With automatic edit

> Use it carefully, as it will edit your files in place. Make sure to commit your changes before to be able to revert if needed.

```sh
docker run --rm --pull always \
  --user $(id -u):$(id -g) \
  --workdir /workspace/ \
  -v "$(pwd):/workspace/" \
  ghcr.io/qgis/pyqgis4-checker:main-ubuntu \
  pyqt5_to_pyqt6.py --logfile /workspace/pyqt6_checker.log .
```

### Use in CI/CD

#### GitHub Actions

```yaml
name: "✅ Linter"

on:
  push:
    branches:
      - main
    paths:
      - "**.py"
      - .github/workflows/linter.yml

  pull_request:
    branches:
      - main
    paths:
      - "**.py"
      - .github/workflows/linter.yml

env:
  PROJECT_FOLDER: "path_to_plugin_folder"

jobs:
  lint-qt6:
    name: PyQGIS 4 Checker (Qt 6️⃣)
    runs-on: ubuntu-latest
    permissions:
      contents: read

    container:
      image: ghcr.io/qgis/pyqgis4-checker:main-ubuntu

    steps:
      - name: Get source code
        uses: actions/checkout@v6

      - name: Run PyQGIS 4 migration check
        run: |
          # write the report into a log file
          pyqt5_to_pyqt6.py --dry_run --logfile pyqt6_checker.log ${{ env.PROJECT_FOLDER }}/
          # trigger an exit code if some incompatibility has been spotted
          pyqt5_to_pyqt6.py ${{ env.PROJECT_FOLDER }}/

      - name: Upload script report if script fails
        uses: actions/upload-artifact@v7
        if: ${{ failure() }}
        with:
          name: pyqgis4-checker-report
          path: pyqt6_checker.log
          retention-days: 7
```

#### GitLab CI

```yaml
stages:
  - lint

variables:
  PROJECT_FOLDER: "path_to_plugin_folder"

lint:qt6:
  image: ghcr.io/qgis/pyqgis4-checker:main-ubuntu
  variables:
    FF_DISABLE_UMASK_FOR_DOCKER_EXECUTOR: "true" # required since the image use a custom user with UID 1000, to avoid permission issues with generated log file and edited files in the repository, we need to disable umask reset in GitLab Runner for this job
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        - "$PROJECT_FOLDER/**/*.py"
        - ".gitlab-ci.yml"
      when: on_success
    - when: never
  before_script:
    # just print some infos from inside the image to check it's working as expected
    - qgis --version
    - python3 -c "from qgis.PyQt.QtCore import QT_VERSION_STR;print(f'Qt {QT_VERSION_STR}')"
    - pyqt5_to_pyqt6.py --help
  script:
    # first, a dry run to get the log file
    - pyqt5_to_pyqt6.py --dry_run --logfile pyqt6_checker.log $PROJECT_FOLDER/
    # then running with edit enabled to
    - pyqt5_to_pyqt6.py $PROJECT_FOLDER/
  artifacts:
    paths:
      - pyqt6_checker.log
    when: always
    access: all
    expire_in: 1 week
```

### Other commands

```sh
# Enter an interactive shell
docker run -it --rm --pull missing \
  ghcr.io/qgis/pyqgis4-checker:main-ubuntu /bin/bash

# Check QGIS and Qt versions
docker run --rm ghcr.io/qgis/pyqgis4-checker:main-ubuntu qgis --version
docker run --rm ghcr.io/qgis/pyqgis4-checker:main-ubuntu \
  python3 -c "from qgis.PyQt.QtCore import QT_VERSION_STR; print(f'Qt {QT_VERSION_STR}')"
```

### Build locally

```sh
docker build --pull --rm \
  --file pyqgis4-checker-ubuntu.dockerfile \
  --tag pyqgis4-checker-ubuntu:local .
```

With BuildKit and cache:

```sh
docker buildx create --name qgisbuilder --driver docker-container --use

docker buildx build --pull --rm \
  --file pyqgis4-checker-ubuntu.dockerfile \
  --cache-from type=local,src=.cache/docker/qgis/ \
  --cache-from type=registry,ref=ghcr.io/qgis/pyqgis4-checker:cache-ubuntu \
  --cache-to type=local,dest=.cache/docker/qgis/,mode=max \
  --load \
  --platform linux/amd64 \
  --tag pyqgis4-checker-ubuntu:local \
  .
```

---

## Docker - Fedora (advanced)

Based on Fedora 42 with **QGIS compiled from source**. Use this image when you need:

- more recent versions of Qt or GDAL than Ubuntu ships
- specific build options: Oracle support, SFCGAL, PDF4Qt...

> [!WARNING]
> This image is significantly larger (~10 GB) and takes much longer to build than the Ubuntu image. For most plugin developers, the Ubuntu image is sufficient.

### Requirements

- Docker >= 28
- Available disk space: ~10 GB

### Run the published image

```sh
docker run -it --rm --pull missing \
  ghcr.io/qgis/pyqgis4-checker:main-fedora /bin/bash
```

### Build locally

```sh
docker buildx create --name qgisbuilder --driver docker-container --use

docker buildx build --pull --rm \
  --file pyqgis4-checker-fedora.dockerfile \
  --build-arg QGIS_GIT_VERSION=master \
  --cache-from type=local,src=.cache/docker/qgis/ \
  --cache-from type=registry,ref=ghcr.io/qgis/pyqgis4-checker:cache-fedora \
  --cache-to type=local,dest=.cache/docker/qgis/,mode=max \
  --load \
  --platform linux/amd64 \
  --tag pyqgis4-checker-fedora:local \
  .
```

> [!NOTE]
> The local cache is stored under `.cache/docker/qgis/`. Clean it up to free disk space, or use `/tmp/docker/cache` instead.

#### Skip recompilation (build only the `stage-run` layer)

When iterating on the runtime environment without changing the QGIS build itself, reuse the compiled binaries from the published image:

```sh
docker buildx build --pull --rm \
  --file pyqgis4-checker-fedora.dockerfile \
  --target stage-run \
  --build-arg BASE_RUN_IMAGE=ghcr.io/qgis/pyqgis4-checker:main-fedora \
  --cache-from type=local,src=.cache/docker/qgis/ \
  --cache-from type=registry,ref=ghcr.io/qgis/pyqgis4-checker:cache-fedora \
  --cache-to type=local,dest=.cache/docker/qgis/,mode=max \
  --load \
  --platform linux/amd64 \
  --tag pyqgis4-checker-fedora:local \
  .
```

---

## Publishing strategy

Docker images are built and published automatically via GitHub Actions:

| Event | Tag |
|---|---|
| Push to `main` | `main-ubuntu`, `main-fedora` |
| Semantic version tag (e.g. `1.2.3`) | `1.2.3-ubuntu`, `1.2-ubuntu`, `latest-ubuntu` |
| Manual dispatch with a specific QGIS version | `3.40-ubuntu` |

---

## Contributing

Install [pre-commit](https://pre-commit.com/) via [pipx](https://pipx.pypa.io/stable/installation/):

```sh
pipx install pre-commit
pre-commit install
```

Run checks manually:

```sh
pre-commit run --all-files
```
