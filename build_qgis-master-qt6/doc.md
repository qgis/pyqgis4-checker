## Create a Docker Image for QGIS Qt6

Everything described in this procedure must be performed in the [official QGIS repo](https://github.com/qgis/QGIS).

:warning: Before proceeding, I had to remove `.ci` from `.dockerignore` in my QGIS repository; otherwise, it wouldn't be copied, and the script `/root/QGIS/.docker/docker-qgis-build.sh` requires it.

Named `qgis-qt6.dockerfile` and placed in `QGIS/.docker`

```sh
docker buildx build -f .docker/qgis-qt6.dockerfile -t qgis-master-qt6 .
```

The build is successful. You can connect to the image using:

```sh
docker run -it --rm --name qgis-master-qt6 qgis-master-qt6:latest /bin/bash
```

To launch QGIS, use the following command:

```sh
docker run --rm \
    -i -t \
    -v ${HOME}:/home/${USER} \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=${DISPLAY} \
    --net=host \
    -e LD_LIBRARY_PATH=/root/QGIS/build/output/lib \
    qgis-qt6 /root/QGIS/build/output/bin/qgis
```
