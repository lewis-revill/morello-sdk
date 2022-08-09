# SPDX-License-Identifier: BSD-3-Clause

CC=gcc
CC_MORELLO=clang
ELF_PATCH=morello_elf
MUSL_HOME=../../musl-bin
CLANG_RESOURCE_DIR=$(shell clang -print-resource-dir)
TARGET?=aarch64-linux-musl_purecap
OUT=bin

all:
	mkdir -p $(OUT)
	$(CC) -o $(OUT)/init.aarch64.docker init.c -static -D MORELLO_DOCKER
	$(CC) -o $(OUT)/init.aarch64 init.c -static

	$(CC_MORELLO) -c -g -march=morello+c64 \
		--target=$(TARGET) --sysroot $(MUSL_HOME) \
		-D MORELLO_DOCKER \
		init.c -o $(OUT)/init.docker.c.o
	$(CC_MORELLO) -fuse-ld=lld -march=morello+c64 \
		--target=$(TARGET) --sysroot $(MUSL_HOME) \
		-D MORELLO_DOCKER \
		-rtlib=compiler-rt \
		$(OUT)/init.docker.c.o \
		-o $(OUT)/init.docker -static
	$(ELF_PATCH) $(OUT)/init.docker
	rm $(OUT)/init.docker.c.o

	$(CC_MORELLO) -c -g -march=morello+c64 \
		--target=$(TARGET) --sysroot $(MUSL_HOME) \
		init.c -o $(OUT)/init.c.o
	$(CC_MORELLO) -fuse-ld=lld -march=morello+c64 \
		--target=$(TARGET) --sysroot $(MUSL_HOME) \
		-rtlib=compiler-rt \
		$(OUT)/init.c.o \
		-o $(OUT)/init -static
	$(ELF_PATCH) $(OUT)/init
	rm $(OUT)/init.c.o

clean:
	rm $(OUT) -fr
