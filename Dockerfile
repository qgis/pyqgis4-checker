# syntax=docker/dockerfile:1.7-labs
# Required syntax parser to handle --exclude option for COPY instructions

# STAGE: BUILD from QGIS Qt6 image
FROM oslandia/qgis-master-qt6:latest AS build

LABEL Author="Julien M. (Oslandia)"

# STAGE: RUN
FROM fedora:39

# Write .pyc files only once. See: https://stackoverflow.com/a/60797635/2556577
ENV PYTHONDONTWRITEBYTECODE 1 \
    # Make sure that stdout and stderr are not buffered. See: https://stackoverflow.com/a/59812588/2556577
    PYTHONUNBUFFERED 0 \
    # Remove assert statements and any code conditional on __debug__. See: https://docs.python.org/3/using/cmdline.html#cmdoption-O
    PYTHONOPTIMIZE 2

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
    # Python packages
    && python3 -m pip install --no-cache-dir --upgrade astpretty tokenize-rt \
    && dnf -y remove python3-pip \
    # clean up
    && dnf clean all

# Reference QGIS headers and Python packages into the Python environment
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH=/usr/local/python:$PYTHONPATH

# Create non-root user
RUN useradd -ms /bin/bash pyqgisdev
USER pyqgisdev
WORKDIR /home/pyqgisdev

# Expose the conversion script as entrypoint - disabled to make it inspectable with an interactive run
# ENTRYPOINT [ "/usr/local/bin/pyqt5_to_pyqt6.py" ]
