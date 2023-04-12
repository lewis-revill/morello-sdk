# Build the Linux Test Project (LTP) for morello using morello-pcuabi-env

This document covers the steps to build the [Linux Test Project](https://git.morello-project.org/morello/morello-linux-ltp) for morello using morello-pcuabi-env.

## Usage

Create the following workspace structure:

```
ltp/
  |-> workspace/
       |-> ltp.env
  |-> docker-compose.yml
```

Create a `docker-compose.yml` file in `ltp/` as follows:

```
# Docker composer file for Morello LTP
version: '3.8'
services:
  ltp-morello-pcuabi-env:
    image: "git.morello-project.org:5050/morello/morello-pcuabi-env/morello-pcuabi-env:latest"
    container_name: "ltp-morello-pcuabi-env"
    volumes:
      - ./workspace:/home/morello/workspace
    tty: true
    restart: unless-stopped
```

Clone the `LTP` repository you want to build in `ltp/workspace`:
```
cd ltp/workspace
git clone https://git.morello-project.org/morello/morello-linux-ltp.git ltp
```

Then, bring up the container (from `ltp/)`:
```
$ docker-compose up -d
```

Create a `ltp.env` file in `ltp/workspace` as follows:

```
export CC=clang
export HOST_CFLAGS="-O2 -Wall"
export HOST_LDFLAGS="-Wall"
export CONFIGURE_OPT_EXTRA="--prefix=/ --host=aarch64-linux-gnu --disable-metadata --without-numa"

export BUILD_DIR=/home/morello/workspace/build_purecap
export LTP_INSTALL="$BUILD_DIR"/install

export TARGET_FEATURE="-march=morello+c64"
export TRIPLE=aarch64-linux-musl_purecap

export KHDR_DIR=/morello/usr/include

export CFLAGS="--target=${TRIPLE} ${TARGET_FEATURE} \
        --sysroot=${MUSL_HOME} \
        -isystem ${KHDR_DIR} -g -Wall"

export LDFLAGS="--target=${TRIPLE} -rtlib=compiler-rt \
        --sysroot=${MUSL_HOME} \
        -fuse-ld=lld -static -L${BUILD_DIR}/lib"

export MAKE_OPTS="TST_NEWER_64_SYSCALL=no TST_COMPAT_16_SYSCALL=no"
export TARGETS="pan tools/apicmds testcases/kernel/syscalls"
```

To enter into the container, run the command:

```
$ docker exec -it -u morello ltp-morello-pcuabi-env /bin/bash
```

Inside the container, run the commands:
```
cd ltp
source /morello/env/morello-pcuabi-env
source ../ltp.env
./build.sh -t cross -o out -ip "${LTP_INSTALL}"
```

The build output will be in `ltp/workspace/build_purecap/install`.

Have a lot of fun!

**Note (1):** Once you started the docker container the files of your project are accessible at `/home/morello/workspace/ltp`.  
**Note (2):** This will build LTP in purecap only.

For further information please refer to the [Docker](https://docs.docker.com/) documentation.
