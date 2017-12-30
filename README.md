# TES3MP-forge

## A container to simplify the packaging of TES3MP for GNU/Linux

<grimkriegor@krutt.org>

This Docker image creates a Debian Jessie build environment, compiles a bunch of dependencies with parameters as such to make the resulting TES3MP GNU/Linux package work on most distros and finally summons [TES3MP-deploy](https://github.com/GrimKriegor/TES3MP-deploy) to build and package TES3MP automatically.

### Getting the image

From Docker Hub

    docker run -v <output-directory>:/build grimkriegor/tes3mp-forge

From source

    git clone https://github.com/GrimKriegor/TES3MP-forge.git
    cd TES3MP-forge
    docker build --name "TES3MP-forge" --build-arg CORES=<build-threads> .
    docker run -v <output-directory>:/build TES3MP-forge

Replace **<output-directory>** with the path of the directory you want to build TES3MP on. The package will also be there.

### Usage

By default TES3MP-forge runs TES3MP-deploy with "--script-upgrade --cmake-local --skip-pkgs" which tells it to check for script upgrades via git, automatically update, and use the build dependencies bundled with this image.

If no parameter is specified on Docker run or start, the default behaviour is to install and package TES3MP.

### Tips

Might be a good idea to get a fresh copy of **libstdc++.so.6** from a recent system and drop it into the package **lib/** directory for increasced compatibility with older systems

You can either inject it directly into the .tar.gz package or put it into **extras/lib/** and have it be included on all future package builds

    mkdir -p <output-directory>/extras/lib
    cp -r --preserve=links /usr/lib/libstdc++.so.6* <output-directory>/extras/lib/

The same can be done with the **version** file, when you are building from hotfix commits but want to keep it compatible with the servers.

    mkdir -p <output-directory>/extras/resources/
    cp version <output-directory>/extras/resources/
