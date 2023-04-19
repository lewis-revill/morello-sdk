# Introduction

## Docker image for morello-sdk based on Debian.

This page contains some simple instructions to get you started on Morello. In less than 10 minutes you should be able to setup a docker container with everything you need to build an application for Morello.

The development kit includes includes:
- [llvm](https://git.morello-project.org/morello/llvm-project-releases)
- [musl libC](https://git.morello-project.org/morello/musl-libc)
- [linux kernel headers](https://git.morello-project.org/morello/morello-linux-headers)
- various utilities

**To set it up please follow the instructions below.**

**Note:** This approach requires a Morello Board to deploy the final application.

If you want to replicate the development environment directly on your system without using docker please follow the instructions at [morello-sdk setup](docs/MORELLO-PCUABI-ENV.md) and use the **morello/mainline** branch of this project.

# Setup

Install docker:
```
$ curl -sSL https://get.docker.com | sh
```

Install docker-compose:

Latest: v2.17.2

Installation command:
```
$ sudo curl -L "https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

Provide correct permissions to docker compose:
```
$ sudo chmod +x /usr/local/bin/docker-compose
```

Test docker-compose:
```
$ docker-compose --version
```

# Usage

Create the following workspace structure:

```
<project>/
  |-> workspace/
  |-> docker-compose.yml
```

**Note:** `<project>` must be replaced by the name of the project you are trying to build. The same thing applies to the rest of the document.  

Create a `docker-compose.yml` file and map the morello directory into `<project>/` as follows:

```
# Docker composer file for Morello Linux
version: '3.8'
services:
  <project>-morello-sdk:
    image: "git.morello-project.org:5050/morello/morello-sdk/morello-sdk:latest"
    container_name: "<project>-morello-sdk"
    volumes:
      - ./workspace:/home/morello/workspace
    tty: true
    restart: unless-stopped
```

Clone the `<project>` you want to build in `<project>/workspace`:
```
cd <project>/workspace
git clone <project-repo>
```

**Note:** To create a simple helloworld project please refer to the relevant [section](#build-an-hello-world-application-using-morello-sdk-development-kit).

Then, bring up the container (from `<project>/)`:
```
$ docker-compose up -d
```

To enter into the container, run the command:

```
$ docker exec -it -u morello <project>-morello-sdk /bin/bash
```

Have a lot of fun!

**Note:** Once you started the docker container the files of your project are accessible at `/home/morello/workspace/<project>`.

## Cleanup the morello-sdk container

**/!\ WARNING: execute this step only if there are no more `<project>s` using the morello-sdk container.**

To recover the space used by the `<project>-morello-sdk` container execute the following commands:

**STEP 1:** Stop all the projects using morello-sdk container.

```
$ docker stop <project>-morello-sdk
```

**STEP 2:** Remove all the files belonging to the morello-sdk container.

```
$ docker image rm git.morello-project.org:5050/morello/morello-sdk/morello-sdk:latest -f
$ docker image prune
```

For further information please refer to the [Docker](https://docs.docker.com/) documentation.

# Build a hello world application using morello-sdk development kit

To write and build a hello world application please make sure you started the morello-sdk container following the instructions listed above.  
Once the container is started, if everything went well, you should be welcomed by the prompt:
```
morello@<container-id>:~/workspace$
```
At this point create the following file and directory structure:
```
workspace/
 |-> helloworld/
      |-> main.c
      |-> Makefile
```
Edit the **Makefile** and insert the code below:
```
# SPDX-License-Identifier: BSD-3-Clause

# This Makefile will compile an helloworld application using Morello Clang and the Musl libc compiled for purecap.

CC=clang
# ELF_PATCH is used to check that the correct elf flag for Morello is present
ELF_PATCH=morello_elf
MUSL_HOME?=../../musl-bin
CLANG_RESOURCE_DIR=$(shell clang -print-resource-dir)

OUT=./bin
# we want the same result no matter where we're cross compiling (x86_64, aarch64)
TARGET?=aarch64-linux-musl_purecap

all:
	mkdir -p $(OUT)
	$(CC) -c -g -march=morello+c64 \
		--target=$(TARGET) --sysroot $(MUSL_HOME) \
		main.c -o $(OUT)/morello-helloworld.c.o
	$(CC) -fuse-ld=lld -march=morello+c64 \
		--target=$(TARGET) --sysroot $(MUSL_HOME) \
		-rtlib=compiler-rt \
		$(OUT)/morello-helloworld.c.o \
		-o $(OUT)/morello-helloworld -static
	$(ELF_PATCH) $(OUT)/morello-helloworld
	rm $(OUT)/morello-helloworld.c.o

clean:
	rm $(OUT)/morello-helloworld
```
Edit **main.c** and insert the code below:
```
/* SPDX-License-Identifier: BSD-3-Clause */

#include <stdio.h>

int main()
{
	printf("Hello from Morello!!\n");

	return 0;
}
```
At this point you have everything you need. Source the development kit environment file:
```
source /morello/env/morello-sdk
``` 
and run:
```
make
```
If everything went well your **helloworld** binary for morello should be waiting for you in **workspace/helloworld/bin**.  

**Note:** the same binary will be accessible outside of the container at: `<project>/workspace/helloworld/bin`.  

## Examples of projects that can be built via morello-sdk

This section containt the instructions to build some projects via morello-sdk:
- [Linux Kernel](docs/LINUX-KERNEL.md)
- [Musl libC](docs/MUSL-LIBC.md)
- [Linux Test Project](docs/LTP.md)
- [morello-doom](docs/MORELLO-DOOM.md)

## Important notes

**/morello/env/morello-sdk** exposes the following environment variables:
```
MORELLO_HOME=/morello
MUSL_HOME=/morello/musl
...
```
**MORELLO_HOME** points to the root directory of the development kit.  
**MUSL_HOME** points to the musl C library binaries.  
The kernel headers are contained in **/morello/usr/include**.  
**clang** compiler is in the path after sourcing **/morello/env/morello-sdk**.  
  
Please make sure that the Makefile of the application you are trying to port to Morello using this development kit is compliant with these assumptions.

# Container verification

morello-sdk generated containers are signed using [cosign](https://github.com/sigstore/cosign). To verify the validity of a container before donwloading it please follow the information contained in the [.cosign](.cosign/README.md) directory.
