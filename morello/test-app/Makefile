# SPDX-License-Identifier: BSD-3-Clause

CC=clang
ELF_PATCH=morello_elf
CMP=cmp -l
GAWK=gawk

OUT=../bin
# we want the same result no matter where we're compiling
TARGET?=aarch64-linux-gnu

all:
	mkdir -p $(OUT)
	$(CC) -c -g -nostdinc -isystem ../musl-bin/include \
		-march=morello+c64 -mabi=purecap main.c -o $(OUT)/main.c.o \
		--target=$(TARGET)
	$(CC) --target=$(TARGET) -fuse-ld=lld -march=morello+c64 -mabi=purecap \
		../musl-bin/lib/crt1.o \
		../musl-bin/lib/crti.o \
		../llvm/lib/clang/11.0.0/lib/linux/clang_rt.crtbegin-morello.o \
		$(OUT)/main.c.o \
		../llvm/lib/clang/11.0.0/lib/linux/clang_rt.crtend-morello.o \
		../musl-bin/lib/crtn.o \
		-nostdlib -L../musl-bin/lib -lc -lm -lgcc -o $(OUT)/main -static
	$(ELF_PATCH) $(OUT)/main

clean:
	rm $(OUT)/main.c.o
	rm $(OUT)/main
