# TES3MP-forge

### A container to simplify the packaging of TES3MP for GNU/Linux

<grimkriegor@krutt.org>

This Docker image creates a Debian Jessie build environment, compiles a bunch of dependencies with parameters as such to make the resulting TES3MP GNU/Linux package work on most distros and finally summons [TES3MP-deploy](https://github.com/GrimKriegor/TES3MP-deploy) to build and package TES3MP automatically.

#### Getting the image

From Docker Hub

    docker run -v <output-folder>:/build grimkriegor/tes3mp-forge

From source

    git clone https://github.com/GrimKriegor/TES3MP-forge.git
    cd TES3MP-forge
    docker build --name "TES3MP-forge" --build-arg CORES=<build-threads> .
    docker run -v <output-folder>:/build TES3MP-forge

#### Usage

By default TES3MP-forge runs TES3MP-deploy with "--script-upgrade --cmake-local --skip-pkgs" which tells it to check for script upgrades via GitHub and use the build dependencies on /usr/local bundled with this image.

If no parameter is specified on Docker run or start, the default behaviour is to install and package TES3MP.
