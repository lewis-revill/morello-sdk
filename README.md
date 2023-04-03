# Introduction

## Docker image for morello-pcuabi-env based on Debian.

This page contains some simple instructions to get you started on Morello. In less than 10 minutes you should be able to setup a docker container with everything you need to build an application for Morello.

**To set it up please follow the instructions below.**

**Note:** This approach requires a Morello Board to deploy the final application.

If you want to replicate the development environment directly on your system without using docker please follow the instructions at [morello-pcuabi-env setup](MORELLO-PCUABI-ENV.md) and use the **morello/mailine** branch of this project.

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

Create a `docker-compose.yml` file and map the morello directory into /morello as follows:

```
# Docker composer file for Morello Linux
version: '3.8'
services:
  <project>-morello-pcuabi-env:
    image: "git.morello-project.org:5050/morello/morello-pcuabi-env/morello-pcuabi-env:latest"
    container_name: "<project>-morello-pcuabi-env"
    volumes:
      - ./workspace:/home/morello/workspace
    tty: true
    restart: unless-stopped
```

Clone the <project> you want to build in <project>/workspace:
```
cd <project>/workspace
git clone <project-repo>
```

Then, bring up the container (from <project>/):
```
$ docker-compose up -d
```

To enter into the container, run the command:

```
$ docker exec -it -u morello <project>-morello-pcuabi-env /bin/bash
```

Have a lot of fun!

**Note (1):** <project> must be replaced by the name of the project you are trying to build.  
**Note (2):** Once you started the docker container the files of your project are accessible at **/home/morello/workspace/<project>**.

## Cleanup the morello-pcuabi-env container

**/!\ WARNING: execute this step only if there are no more <project>s using the morello-pcuabi-env container.**

To recover the space used by the <project>-morello-pcuabi-env container execute the following commands:

**STEP 1:** Stop all the projects using morello-pcuabi-env container.

```
$ docker stop <project>-morello-pcuabi-env
```

**STEP 2:** Remove all the files belonging to the morello-pcuabi-env container.

```
$ docker image rm git.morello-project.org:5050/morello/morello-pcuabi-env/morello-pcuabi-env:latest -f
$ docker image prune
```

For further information please refer to the [Docker](https://docs.docker.com/) documentation.

# Build an hello world application using morello-pcuabi-env development kit

To write and build an hello world application please make sure you started the morello-pcuabi-env container following the instructions listed above.  
Once the cointainer is started, if everything went well, you sould be welcomed by the prompt:
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

CC=clang
ELF_PATCH=morello_elf
CMP=cmp -l
GAWK=gawk
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
At this point you have everything you need. Source the develpment kit enviromnent file:
```
source /morello/env/morello-pcuabi-env
``` 
and run:
```
make
```
If everything went well your **helloworld** binary for morello should be waiting for you in **workspace/helloworld/bin**.  

**Note:** the same binary will be accessible outside of the container at: **<project>/workspace/helloworld/bin**.  

## Important notes

**/morello/env/morello-pcuabi-env** exposes the following environment variables:
```
MORELLO_HOME=/morello
MUSL_HOME=/morello/musl
...
```
**MORELLO_HOME** points to the root directory of the development kit.  
**MUSL_HOME** points to the musl C library binaries.  
The kernel headers are contained in **/morello/usr/include**.  
**clang** compiler is in the path after sourcing **/morello/env/morello-pcuabi-env**.  
  
Please make sure that the Makefile of the application you are trying to port to Morello using this development kit is compliant with these assumptions.