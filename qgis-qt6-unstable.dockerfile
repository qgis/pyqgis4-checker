# syntax=docker/dockerfile:1.7-labs
# Required syntax parser to handle --exclude option for COPY instructions

# Arguments to customize build
ARG LINUX_DISTRO_NAME=fedora
ARG LINUX_DISTRO_VERSION=39
ARG QGIS_GIT_VERSION=master

# -- STAGE: BUILD from QGIS Qt6 image
FROM qgis/qgis3-qt6-build-deps-bin-only:${QGIS_GIT_VERSION} as build

ARG QGIS_GIT_VERSION

ENV PUSH_TO_CDASH=true \
    WITH_QT5=OFF \
    BUILD_WITH_QT6=ON \
    WITH_QUICK=ON \
    WITH_3D=ON \
    WITH_GRASS7=OFF \
    WITH_GRASS8=ON \
    WITH_QTWEBENGINE=ON \
    WITH_PDF4QT=ON \
    LD_PRELOAD='' \
    WITH_CLAZY=OFF \
    WITH_COMPILE_COMMANDS=OFF \
    ENABLE_UNITY_BUILDS=ON \
    CCACHE_DIR=/root/.ccache \
    SEGFAULT_SIGNALS="abrt segv" \
    CTEST_BUILD_COMMAND=/usr/bin/ninja \
    CTEST_PARALLEL_LEVEL=1 \
    CTEST_SOURCE_DIR=/root/QGIS \
    CTEST_BUILD_DIR=/root/QGIS/build \
    QT_VERSION=6 \
    QGIS_NO_OVERRIDE_IMPORT=1 \
    QGIS_CONTINUOUS_INTEGRATION_RUN=true \
    PUSH_TO_CDASH=false \
    XDG_RUNTIME_DIR=/tmp \
    QGIS_MINIO_HOST=minio \
    QGIS_MINIO_PORT=9000 \
    QGIS_WEBDAV_HOST=webdav \
    QGIS_WEBDAV_PORT=80 \
    TERM=xterm

# clone QGIS source code and launch QGIS build
RUN --mount=type=cache,target=/root/.ccache \
    ccache --show-stats \
    && git clone --depth 1 --filter=blob:none --single-branch -b ${QGIS_GIT_VERSION} https://github.com/qgis/QGIS.git /root/QGIS/ \
    && rm -rf /root/QGIS/.git \
    && /root/QGIS/.docker/docker-qgis-build.sh

# -- STAGE: RUN
FROM ${LINUX_DISTRO_NAME}:${LINUX_DISTRO_VERSION}

LABEL org.opencontainers.image.authors="qgis+qt6@oslandia.com"

# Write .pyc files only once. See: https://stackoverflow.com/a/60797635/2556577
ENV PYTHONDONTWRITEBYTECODE=1 \
    # Make sure that stdout and stderr are not buffered. See: https://stackoverflow.com/a/59812588/2556577
    PYTHONUNBUFFERED=0 \
    # Remove assert statements and any code conditional on __debug__. See: https://docs.python.org/3/using/cmdline.html#cmdoption-O
    PYTHONOPTIMIZE=2

# Import generated files from build stage
COPY --from=build --exclude=share/qgis/i18n/* --exclude=share/qgis/resources/data/* /root/QGIS/build/output/ /usr/local/
COPY --from=build /root/QGIS/build/usr/lib/ /usr/lib/

# TEMPORARY: GET THE LATEST SCRIPT VERSION WAITING FOR SOURCE IMAGE TO BE UPDATED
# COPY --from=build /root/QGIS/scripts/pyqt5_to_pyqt6/* /usr/local/bin/
ADD --chmod=755 https://github.com/qgis/QGIS/raw/refs/heads/master/scripts/pyqt5_to_pyqt6/pyqt5_to_pyqt6.py /usr/local/bin/

# Install required dependencies
RUN dnf install --refresh -y \
    draco \
    gdal \
    gdal-python-tools \
    gpsbabel \
    grass \
    gsl \
    libzip \
    PDAL \
    PDAL-libs \
    perl-YAML-Tiny \
    poppler-utils \
    protobuf-lite \
    python3-mock \
    python3-oauthlib \
    python3-OWSLib \
    python3-pip \
    python3-pyqt6 \
    python3-qscintilla-qt6 \
    # python3-termcolor \
    # PyQt-builder \
    qca-qt6 \
    qpdf \
    qt6-qt3d \
    qt6-qtbase \
    qt6-qttools-static \
    qt6-qtwebengine \
    qtkeychain-qt6 \
    qwt-qt6 \
    spatialindex \
    util-linux \
    # clean up
    && dnf clean all

# Reference QGIS headers and Python packages into the Python environment
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH \
    PYTHONPATH=/usr/local/python:$PYTHONPATH

# Set locales to avoid Qt messing up with encoding
RUN localedef -i en_US -f UTF-8 en_US.UTF-8 || true
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Create non-root user
RUN useradd -ms /bin/bash qgis-user -p "$(openssl passwd -1 qgis4qt6)"
USER qgis-user
WORKDIR /home/qgis-user
