# -- GLOBAL

# Arguments to customize build
ARG LINUX_DISTRO_NAME=ubuntu
ARG LINUX_DISTRO_VERSION=25.10
ARG QGIS_GIT_VERSION=master
ARG BASE_RUN_IMAGE=stage-build

FROM ${LINUX_DISTRO_NAME}:${LINUX_DISTRO_VERSION} AS stage-build

LABEL org.opencontainers.image.title="QGIS with Qt6 (UbuntuGIS)" \
    org.opencontainers.image.description="QGIS built with Qt6 from source code on UbuntuGIS base image."

# Write .pyc files only once. See: https://stackoverflow.com/a/60797635/2556577
ENV PYTHONDONTWRITEBYTECODE=1 \
    # Make sure that stdout and stderr are not buffered. See: https://stackoverflow.com/a/59812588/2556577
    PYTHONUNBUFFERED=0 \
    # Remove assert statements and any code conditional on __debug__. See: https://docs.python.org/3/using/cmdline.html#cmdoption-O
    PYTHONOPTIMIZE=2

# ADD QGIS UBUNTU NIGHTLY REPOSITORY
RUN apt update && apt install --no-install-recommends -y \
    ca-certificates gnupg software-properties-common wget \
    # add QGIS key and repository
    && mkdir -p /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] https://ubuntu.qgis.org/ubuntu-nightly $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/qgis.list \
    && apt update

# INSTALL QGIS QT6 PACKAGE
RUN apt install -y qgis-qt6 \
    && apt autoremove \
    && rm -rf /var/lib/apt/lists/*
