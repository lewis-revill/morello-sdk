# Build the morello-doom for morello using morello-pcuabi-env

This document covers the steps to build the [morello-doom](https://github.com/fvincenzo/morello-doom) for morello using morello-pcuabi-env.

## Usage

Create the following workspace structure:

```
morello-doom/
  |-> workspace/
       |-> morello-doom.env
  |-> docker-compose.yml
```

Create a `docker-compose.yml` file and map the morello directory into `morello-doom/` as follows:

```
# Docker composer file for Morello morello-doom
version: '3.8'
services:
  morello-doom-morello-pcuabi-env:
    image: "git.morello-project.org:5050/morello/morello-pcuabi-env/morello-pcuabi-env:latest"
    container_name: "morello-doom-morello-pcuabi-env"
    volumes:
      - ./workspace:/home/morello/workspace
    tty: true
    restart: unless-stopped
```

Clone the `morello-doom` you want to build in `morello-doom/workspace`:
```
cd morello-doom/workspace
git clone https://github.com/fvincenzo/morello-doom.git
```

Then, bring up the container (from `morello-doom/)`:
```
$ docker-compose up -d
```

Create a `morello-doom.env` file and map the morello directory into `morello-doom/workspace` as follows:

```
export CC=clang
export CC_SIZE=llvm-size
export ELF_PATCH=morello_elf
export SYS_HEADERS=/morello/usr/include/
```

To enter into the container, run the command:

```
$ docker exec -it -u morello morello-doom-morello-pcuabi-env /bin/bash
```

Inside the container, run the commands:
```
cd morello-doom/doom
source /morello/env/morello-pcuabi-env
source ../morello-doom.env
make
```

**Optional: ** Build the sound server:

```
cd morello-doom/sndserv
make
```

Have a lot of fun!

**Note (1):** The sound server should be built after doom.
**Note (2):** `-j<N>` where **N** is the number of cores can ben added to the last `make` command.  
**Note (3):** Once you started the docker container the files of your project are accessible at `/home/morello/workspace/morello-doom`.

For further information please refer to the [Docker](https://docs.docker.com/) documentation.
