# -- GLOBAL

# Arguments to customize build
ARG LINUX_DISTRO_NAME=ubuntu
ARG LINUX_DISTRO_VERSION=25.10
ARG QGIS_GIT_VERSION=master
ARG BASE_RUN_IMAGE=stage-build

FROM ${LINUX_DISTRO_NAME}:${LINUX_DISTRO_VERSION} AS stage-build

LABEL org.opencontainers.image.title="QGIS with Qt6 (Ubuntu)" \
    org.opencontainers.image.description="QGIS built with Qt6 from source code on Ubuntu base image." \
    org.opencontainers.image.source="https://github.com/qgis/pyqgis4-checker" \
    org.opencontainers.image.licenses="GPL-2.0-or-later"

# Write .pyc files only once. See: https://stackoverflow.com/a/60797635/2556577
ENV PYTHONDONTWRITEBYTECODE=1 \
    # Make sure that stdout and stderr are not buffered. See: https://stackoverflow.com/a/59812588/2556577
    PYTHONUNBUFFERED=0 \
    # Remove assert statements and any code conditional on __debug__. See: https://docs.python.org/3/using/cmdline.html#cmdoption-O
    PYTHONOPTIMIZE=2 \
    # Set locale
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# ADD QGIS UBUNTU NIGHTLY REPOSITORY
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update && apt-get install --no-install-recommends -y \
    # tools to add QGIS repository
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    wget \
    # add QGIS key and repository
    && mkdir -p /etc/apt/keyrings \
    && wget -qO /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] https://ubuntu.qgis.org/ubuntu-nightly $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/qgis.list \
    && apt-get update

# Add PyQGIS migration script
ADD --chmod=755 https://github.com/qgis/QGIS/raw/refs/heads/master/scripts/pyqt5_to_pyqt6/pyqt5_to_pyqt6.py /usr/local/bin/


# INSTALL QGIS QT6 PACKAGE AND DEPENDENCIES
RUN apt-get install --no-install-recommends -y \
    python3-qgis \
    python3-pyqt6.qtquick \
    qgis-qt6 \
    qgis-plugin-grass \
    # python tooling
    python3-pip \
    python3-wheel \
    # migration script dependencies
    && python3 -m pip install --no-cache-dir --upgrade astpretty tokenize-rt --break-system-packages \
    # cleanup
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Reference QGIS Python packages into the Python environment
ENV PYTHONPATH=/usr/lib/python3/dist-packages:$PYTHONPATH

# Create non-root user
RUN useradd -ms /bin/bash quser \
    && groupadd -f sudo \
    && usermod -aG sudo quser \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER quser
WORKDIR /home/quser

# Default command
CMD ["/bin/bash"]
