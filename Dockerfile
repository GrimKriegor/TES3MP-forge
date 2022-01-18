FROM debian:buster as builder

ENV FORGE_VERSION 2.3.0

ARG BUILD_THREADS=4

ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib

RUN echo deb http://deb.debian.org/debian buster-backports main >> /etc/apt/sources.list \
    && cat /etc/apt/sources.list | sed "s/deb /deb-src /g" >> /etc/apt/sources.list \
    && sed -i "s/ main/ main contrib/g" /etc/apt/sources.list \
    && apt-get update \
    && apt-get -y install \
        build-essential \
        git \
        wget

RUN apt-get -y build-dep \
        libmygui-dev \
    && apt-get -y install \
        libfreetype6-dev \
    && cd /tmp \
    && git clone https://github.com/MyGUI/mygui.git mygui \
    && cd mygui \
    && git checkout 82fa8d4fdcaa06cf96dfec8a057c39cbaeaca9c \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_INSTALL_PREFIX=/usr/local .. \
        -DMYGUI_BUILD_DEMOS=OFF \
        -DMYGUI_BUILD_PLUGINS=OFF \
        -DMYGUI_BUILD_TOOLS=OFF \
        -DMYGUI_RENDERSYSTEM=1 \
    && make -j ${BUILD_THREADS} \
    && make install \
    && rm -rf /tmp/mygui

RUN cd /tmp \
    && git clone https://github.com/bulletphysics/bullet3.git bullet \
    && cd bullet \
    && mkdir build \
    && cd build \
    && git checkout tags/2.87 \
    && cmake \
        -DBUILD_SHARED_LIBS=1 \
        -DINSTALL_LIBS=1 \
        -DINSTALL_EXTRA_LIBS=1 \
        -DUSE_DOUBLE_PRECISION=1 \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_CPU_DEMOS=0 \
        -DBUILD_BULLET2_DEMOS=0 \
        -DBUILD_OPENGL3_DEMOS=0 \
        -DBUILD_UNIT_TESTS=0 \
        -DCMAKE_INSTALL_PREFIX=/usr/local .. \
    && make -j ${BUILD_THREADS} \
    && make install \
    && rm -rf /tmp/bullet

RUN apt-get -y build-dep \
        libopenscenegraph-3.4-dev \
    && cd /tmp \
    && git clone -b 3.6 https://github.com/OpenMW/osg.git \
    && cd osg \
    && mkdir build \
    && cd build \
    && cmake \
        -DBUILD_OSG_DEPRECATED_SERIALIZERS=0 \
        -DBUILD_OSG_PLUGINS_BY_DEFAULT=0 \
        -DBUILD_OSG_PLUGIN_BMP=1 \
        -DBUILD_OSG_PLUGIN_DDS=1 \
        -DBUILD_OSG_PLUGIN_JPEG=1 \
        -DBUILD_OSG_PLUGIN_OSG=1 \
        -DBUILD_OSG_PLUGIN_PNG=1 \
        -DBUILD_OSG_PLUGIN_SHADOW=1 \
        -DBUILD_OSG_PLUGIN_TGA=1 \
        -DCMAKE_INSTALL_PREFIX=/usr/local .. \
    && make -j ${BUILD_THREADS} \
    && make install \
    && rm -rf /tmp/osg

FROM debian:buster

LABEL maintainer="Grim Kriegor <grimkriegor@krutt.org>"
LABEL description="A container to simplify the packaging of TES3MP for GNU/Linux"

ARG BUILD_THREADS=4
ENV BUILD_THREADS=${BUILD_THREADS}

ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib

COPY --from=builder /usr/local /usr/local

RUN apt-get update \
    && apt-get -y install \
        build-essential \
        cmake \
        git \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libboost-all-dev \
        libfreetype6 \
        libluajit-5.1-dev \
        liblz4-dev \
        libmp3lame0 \
        libncurses5-dev \
        libopenal-dev \
        libopus0 \
        libpng16-16 \
        libqt5opengl5-dev \
        libsdl2-dev \
        libswscale-dev \
        libtheora0 \
        libunshield-dev \
        lsb-release \
        qt5-default \
        qtbase5-dev \
        qtbase5-dev-tools \
        unzip \
        wget

RUN git config --global user.email "nwah@mail.com" \
    && git config --global user.name "N'Wah" \
    && git clone https://github.com/GrimKriegor/TES3MP-deploy.git /deploy \
    && mkdir /build

VOLUME [ "/build" ]
WORKDIR /build

ENTRYPOINT [ "/bin/bash", "/deploy/tes3mp-deploy.sh", "--script-upgrade", "--cmake-local", "--skip-pkgs", "--handle-corescripts" ]
CMD [ "--install", "--make-package" ]
