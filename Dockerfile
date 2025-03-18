# syntax=docker/dockerfile:1.7-labs
# Required syntax parser to handle --exclude option for COPY instructions

# STAGE: BUILD from QGIS Qt6 image
FROM oslandia/qgis-master-qt6:latest AS build

LABEL Author="Julien M. (Oslandia)"

RUN cd /root/QGIS/build/ \
    && cmake --install ./

# STAGE: RUN
FROM fedora:39

# Write .pyc files only once. See: https://stackoverflow.com/a/60797635/2556577
ENV PYTHONDONTWRITEBYTECODE 1
# Make sure that stdout and stderr are not buffered. See: https://stackoverflow.com/a/59812588/2556577
ENV PYTHONUNBUFFERED 1
# Remove assert statements and any code conditional on __debug__. See: https://docs.python.org/3/using/cmdline.html#cmdoption-O
ENV PYTHONOPTIMIZE 2

# Import generated files from build stage
COPY --from=build --exclude=share/qgis/i18n/* --exclude=share/qgis/resources/data/* /root/QGIS/build/install/ /usr/local/
COPY --from=build /root/QGIS/scripts/pyqt5_to_pyqt6/* /usr/local/bin/

# Install required dependencies
RUN dnf install -y python3-pip python3-pyqt6 python3-qscintilla-qt6 \
    && python3 -m pip install --no-cache-dir --upgrade astpretty tokenize-rt \
    && dnf -y remove python3-pip \
    && dnf clean all

# Reference QGIS Python packages into the Python environment
ENV PYTHONPATH=/usr/local/share/qgis/python:$PYTHONPATH

# Create non-root user
RUN useradd -ms /bin/bash pyqgisdev
USER pyqgisdev
WORKDIR /home/pyqgisdev

# Expose the conversion script as entrypoint - disabled to make it inspectable with an interactive run
# ENTRYPOINT [ "/usr/local/bin/pyqt5_to_pyqt6.py" ]
