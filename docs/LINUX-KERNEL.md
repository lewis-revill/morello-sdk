# Build the linux kernel for morello using morello-sdk

This document covers the steps to build the [linux kernel](https://git.morello-project.org/morello/kernel/linux) for morello using morello-sdk.

## Usage

Create the following workspace structure:

```
linux/
  |-> workspace/
       |-> linux.env
  |-> docker-compose.yml
```

Create a `docker-compose.yml` file and map the morello directory into `linux/` as follows:

```
# Docker composer file for Morello Linux
version: '3.8'
services:
  linux-morello-sdk:
    image: "git.morello-project.org:5050/morello/morello-sdk/morello-sdk:latest"
    container_name: "linux-morello-sdk"
    volumes:
      - ./workspace:/home/morello/workspace
    tty: true
    restart: unless-stopped
```

Clone the `linux` you want to build in `linux/workspace`:
```
cd linux/workspace
git clone https://git.morello-project.org/morello/kernel/linux.git
```

Then, bring up the container (from `linux/)`:
```
$ docker-compose up -d
```

Create a `linux.env` file and map the morello directory into `linux/workspace` as follows:

```
export ARCH=arm64
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export LLVM=1
export KBUILD_OUTPUT=../linux-out
```

To enter into the container, run the command:

```
$ docker exec -it -u morello linux-morello-sdk /bin/bash
```

Inside the container, run the commands:
```
cd linux
source /morello/env/morello-sdk
source ../linux.env
make mrproper && make morello_transitional_pcuabi_defconfig && make
```

Have a lot of fun!

**Note (1):** `-j<N>` where **N** is the number of cores can ben added to the last `make` command.  
**Note (2):** Once you started the docker container the files of your project are accessible at `/home/morello/workspace/linux`.

For further information please refer to the [Docker](https://docs.docker.com/) documentation.
