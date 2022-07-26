# SPDX-License-Identifier: BSD-3-Clause

CC=clang
ELF_PATCH=morello_elf
CMP=cmp -l
GAWK=gawk
MUSL_HOME=../../musl-bin
CLANG_RESOURCE_DIR=$(shell clang -print-resource-dir)

OUT=../bin
# we want the same result no matter where we're cross compiling (x86_64, aarch64)
TARGET?=aarch64-linux-musl_purecap

all:
	mkdir -p $(OUT)
	$(CC) -c -g -march=morello+c64 \
		--target=$(TARGET) --sysroot $(MUSL_HOME) \
		main.c -o $(OUT)/morello-heap.c.o
	$(CC) -fuse-ld=lld -march=morello+c64 \
		--target=$(TARGET) --sysroot $(MUSL_HOME) \
		-rtlib=compiler-rt \
		$(OUT)/morello-heap.c.o \
		-o $(OUT)/morello-heap -static
	$(ELF_PATCH) $(OUT)/morello-heap
	rm $(OUT)/morello-heap.c.o

clean:
	rm $(OUT)/morello-heap
