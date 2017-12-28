# Base the container in Debian Jessie
FROM debian:jessie

# Assign some labels
LABEL maintainer="Grim Kriegor <grimkriegor@krutt.org>"
LABEL description="A script to simplify the installation, upgrade and packaging of TES3MP"

# Environment variables
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib

# Edit sources.list to include source and contrib repositories
RUN cat /etc/apt/sources.list | sed "s/deb /deb-src /g" >> /etc/apt/sources.list
RUN sed -i "s/ main/ main contrib/g" /etc/apt/sources.list

RUN apt-get update
RUN apt-get -y install build-essential lsb-release git wget

# Create a temporary folder where to build the dependencies
RUN mkdir /dependencies

## GCC
RUN apt-get -y install libgmp-dev libmpfr-dev libmpc-dev
RUN apt-get -y build-dep gcc
RUN cd /dependencies && \
    wget ftp://ftp.uvsq.fr/pub/gcc/releases/gcc-6.4.0/gcc-6.4.0.tar.gz && \
    tar xvf gcc-6.4.0.tar.gz && \
    cd gcc-6.4.0 && \
    ./configure --program-suffix=-6 --enable-languages=c,c++ --disable-multilib && \
    make && \
    make install
RUN update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/local/bin/g++-6

## CMake
RUN apt-get -y build-dep cmake
RUN cd /dependencies && \
    git clone https://github.com/Kitware/CMake.git && \
    cd CMake && \
    git checkout tags/v3.5.2 && \
    ./configure --prefix=/usr/local && \
    make && \
    make install

## Boost
RUN apt-get -y build-dep libboost-all-dev
RUN cd /dependencies && \
    wget https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz && \
    tar xvf boost_1_64_0.tar.gz && \
    cd boost_1_64_0 && \
    ./bootstrap.sh --prefix=/usr/local #&& \
    ./b2 --with=all -j 2 install

## MyGUI
RUN apt-get -y install libfreetype6-dev
RUN apt-get -y build-dep libmygui-dev
RUN cd /dependencies && \
    git clone https://github.com/MyGUI/mygui.git MyGUI && \
    cd MyGUI && \
    git checkout 82fa8d4fdcaa06cf96dfec8a057c39cbaeaca9c && \
    mkdir build && \
    cd build && \
    cmake -DMYGUI_RENDERSYSTEM=1 -DMYGUI_BUILD_DEMOS=OFF -DMYGUI_BUILD_TOOLS=OFF -DMYGUI_BUILD_PLUGINS=OFF -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make && \
    make install

## OpenSceneGraph
RUN apt-get -y build-dep libopenscenegraph-dev
RUN cd /dependencies && \
    git clone https://github.com/scrawl/osg.git && \
    cd osg && \
    mkdir build && \
    cd build && \
    cmake -DBUILD_OSG_PLUGINS_BY_DEFAULT=0 -DBUILD_OSG_PLUGIN_OSG=1 -DBUILD_OSG_PLUGIN_DDS=1 -DBUILD_OSG_PLUGIN_TGA=1 -DBUILD_OSG_PLUGIN_BMP=1 -DBUILD_OSG_PLUGIN_JPEG=1 -DBUILD_OSG_PLUGIN_PNG=1 -DBUILD_OSG_DEPRECATED_SERIALIZERS=0 -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make && \
    make install

## QT5
RUN cd /dependencies && \
    git clone git://code.qt.io/qt/qt5.git && \
    cd qt5 && \
    git checkout 5.5 && \
    ./init-repository && \
    ./configure -opensource -nomake examples -nomake tests --prefix=/usr/local && \
    make && \
    make install

## FFMPEG
RUN build-dep ffmpeg
RUN apt-get install yasm libmp3lame-dev libopus-dev
RUN cd /dependencies && \
    git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg && \
    cd ffmpeg && \
    ./configure --prefix=/usr/local --enable-shared --enable-gpl --enable-libvorbis --enable-libtheora --enable-libmp3lame --enable-libopus && \
    make && \
    make install

# TES3MP-deploy build and packaging script
RUN git clone https://github.com/GrimKriegor/TES3MP-deploy.git build/

# Remove build files
RUN rm -rf /dependencies

# Expose the build directory as a volume
VOLUME [ "/build" ]

# Declare entrypoint and default arguments
WORKDIR /build
ENTRYPOINT [ "su", "-c", "/build/tes3mp-deploy.sh", "--cmake-local" ]
CMD [ "--install", "--make-package", "--skip-pkgs" ]
