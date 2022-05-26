# SPDX-License-Identifier: BSD-3-Clause

CC=gcc
OUT=bin

all:
	mkdir -p $(OUT)
	$(CC) -o $(OUT)/heartbeat heartbeat.c -static #-D MORELLO_DEBUG

clean:
	rm $(OUT) -fr
