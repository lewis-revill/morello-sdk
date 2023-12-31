# Build the musl libC for morello using morello-sdk

This document covers the steps to build the [musl libC](https://git.morello-project.org/morello/musl-libc) for morello using morello-sdk.

## Usage

Create the following workspace structure:

```
musl/
  |-> workspace/
       |-> musl.env
  |-> docker-compose.yml
```

Create a `docker-compose.yml` file and map the morello directory into `musl/` as follows:

```
# Docker composer file for Morello musl
version: '3.8'
services:
  musl-morello-sdk:
    image: "git.morello-project.org:5050/morello/morello-sdk/morello-sdk:latest"
    container_name: "musl-morello-sdk"
    volumes:
      - ./workspace:/home/morello/workspace
    tty: true
    restart: unless-stopped
```

Clone the `musl` you want to build in `musl/workspace`:
```
cd musl/workspace
git clone https://git.morello-project.org/morello/musl-libc.git musl
```

Then, bring up the container (from `musl/)`:
```
$ docker-compose up -d
```

Create a `musl.env` file and map the morello directory into `musl/workspace` as follows:

```
export MUSL_BIN=$(pwd)/../musl-bin
```

To enter into the container, run the command:

```
$ docker exec -it -u root musl-morello-sdk /bin/bash
```

Inside the container, run the commands:
```
cd musl
source /morello/env/morello-sdk
source ../musl.env
CC=clang ./configure \
		--enable-morello \
		--target=aarch64-linux-musl_purecap \
		--prefix=${MUSL_BIN}
make
make install
```

Have a lot of fun!

**Note (1):** `make` can be substituted with `make -j<N>` where **N** is the number of cores.  
**Note (2):** Once you started the docker container the files of your project are accessible at `/home/morello/workspace/musl`.

For further information please refer to the [Docker](https://docs.docker.com/) documentation.
