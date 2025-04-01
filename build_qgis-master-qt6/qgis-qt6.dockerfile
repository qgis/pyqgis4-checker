FROM qgis/qgis3-qt6-build-deps-bin-only:master

COPY . /root/QGIS

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
    PUSH_TO_CDASH=fals \
    XDG_RUNTIME_DIR=/tmp \
    QGIS_MINIO_HOST=minio \
    QGIS_MINIO_PORT=9000 \
    QGIS_WEBDAV_HOST=webdav \
    QGIS_WEBDAV_PORT=80 \
    TERM=xterm

RUN /root/QGIS/.docker/docker-qgis-build.sh
