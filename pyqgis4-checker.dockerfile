# Arguments to customize build
ARG BASE_IMAGE=ghcr.io/qgis/qgis-qt6-unstable:main

FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="PyQGIS 4 Checker image" \
    org.opencontainers.image.description="QGIS based on Qt6 with the PyQGIS migration script" \
    org.opencontainers.image.source="https://github.com/qgis/pyqgis4-checker" \
    org.opencontainers.image.licenses="GPL-2.0-or-later"

# Switch back to root to perform privileged operations
USER root

# Install required dependencies
RUN dnf install --nodocs --refresh -y python3-pip python3-wheel \
    # Python packages
    && python3 -m pip install --no-cache-dir --upgrade astpretty tokenize-rt \
    && dnf -y remove python3-pip python3-wheel \
    # clean up
    && dnf autoremove -y \
    && dnf clean all \
    && rm -rf /var/cache/dnf/*

# Create non-root user dedicated to PyQGIS development
# -m -> Create the user's home directory
# -s /bin/bash -> Set as the user's
RUN useradd -ms /bin/bash pyqgisdev \
    && groupadd -f wheel \
    && usermod -aG wheel pyqgisdev

# TEMPORARY: GET THE LATEST SCRIPT VERSION WAITING FOR SOURCE IMAGE TO BE UPDATED
# COPY --from=build /root/QGIS/scripts/pyqt5_to_pyqt6/* /usr/local/bin/
ADD --chmod=755 https://github.com/qgis/QGIS/raw/refs/heads/master/scripts/pyqt5_to_pyqt6/pyqt5_to_pyqt6.py /usr/local/bin/

# Switch to the non-root user
USER pyqgisdev
WORKDIR /home/pyqgisdev

# Expose the conversion script as entrypoint - disabled to make it inspectable with an interactive run
# ENTRYPOINT [ "/usr/local/bin/pyqt5_to_pyqt6.py" ]
