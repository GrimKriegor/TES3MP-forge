# TES3MP-packager

### A container to simplify the packaging of TES3MP for GNU/Linux

<grimkriegor@krutt.org>

**Usage information:**

This Docker image creates a Debian Jessie build environment, compiles a bunch of dependencies with parameters as such to make the resulting TES3MP GNU/Linux package work on most distros and finally summons [TES3MP-deploy](https://github.com/GrimKriegor/TES3MP-deploy) to build and package TES3MP automatically.

Pull image from Docker Hub

    docker run -v <output-folder>:/build GrimKriegor/TES3MP-packager

Build image manually

    git clone https://github.com/GrimKriegor/TES3MP-packager.git
    cd TES3MP-packager
    docker build --name "TES3MP-packager" --build-arg CORES=<build-threads> .
    docker run -v <output-folder>:/build TES3MP-packager

