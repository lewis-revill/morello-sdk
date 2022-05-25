# SPDX-License-Identifier: BSD-3-Clause

CC=gcc
OUT=bin

all:
	mkdir -p $(OUT)
	$(CC) -o $(OUT)/init init.c -static -D MORELLO_DOCKER
	$(CC) -o $(OUT)/init.vm init.c -static

clean:
	rm $(OUT) -fr
