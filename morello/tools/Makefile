# SPDX-License-Identifier: BSD-3-Clause

CC=clang
OUT=../bin

all:
	mkdir -p $(OUT)
	$(CC) -o $(OUT)/morello_elf morello_elf.c
	$(CC) -o $(OUT)/morello_rt_toolchain morello_rt_toolchain.c

clean:
	rm $(OUT)/morello_elf
	rm $(OUT)/morello_rt_toolchain
