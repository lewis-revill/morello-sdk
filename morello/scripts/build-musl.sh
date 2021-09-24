#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

# we want the same result no matter where we're compiling

mkdir -p bin
# Build compiler-rt
clang --target=aarch64-linux-gnu -march=morello+c64 -mabi=purecap \
    -c llvm-project/compiler-rt/lib/crt/crtbegin.c \
    -o llvm/lib/clang/11.0.0/lib/linux/clang_rt.crtbegin-morello.o
clang --target=aarch64-linux-gnu -march=morello+c64 -mabi=purecap \
    -c llvm-project/compiler-rt/lib/crt/crtend.c \
    -o llvm/lib/clang/11.0.0/lib/linux/clang_rt.crtend-morello.o

_NCORES=$(nproc --all)

# Build musl
cd musl
mkdir -p ../musl-bin
CC=clang ./configure --prefix=$(realpath $(pwd)/../musl-bin) --disable-shared --enable-morello --enable-libshim --target=aarch64-linux-gnu
if [ "$?" != 0 ]; then
    exit 1
else
    make -j$_NCORES
    make install
fi

