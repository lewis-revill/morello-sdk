# SPDX-License-Identifier: BSD-3-Clause

CC=clang
ELF_PATCH=morello_elf
CMP=cmp -l
GAWK=gawk
MUSL_LIB=../../musl-bin/lib
CLANG_RESOURCE_DIR=$(shell clang -print-resource-dir)

OUT=../bin
# we want the same result no matter where we're cross compiling (x86_64, aarch64)
TARGET?=aarch64-linux-gnu

all:
	mkdir -p $(OUT)
	$(CC) -c -g -nostdinc -isystem ../../musl-bin/include \
		-march=morello+c64 -mabi=purecap main.c -o $(OUT)/morello-heap.c.o \
		--target=$(TARGET)
	$(CC) --target=$(TARGET) -fuse-ld=lld -march=morello+c64 -mabi=purecap \
		$(MUSL_LIB)/crt1.o \
		$(MUSL_LIB)/crti.o \
		$(CLANG_RESOURCE_DIR)/lib/linux/clang_rt.crtbegin-morello.o \
		$(OUT)/morello-heap.c.o \
		$(CLANG_RESOURCE_DIR)/lib/linux/libclang_rt.builtins-morello.a \
		$(CLANG_RESOURCE_DIR)/lib/linux/clang_rt.crtend-morello.o \
		$(MUSL_LIB)/crtn.o \
		-nostdlib -L$(MUSL_LIB) -lc -o $(OUT)/morello-heap -static
	$(ELF_PATCH) $(OUT)/morello-heap

clean:
	rm $(OUT)/morello-heap.c.o
	rm $(OUT)/morello-heap
