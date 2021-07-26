#!/usr/bin/env bash

# Build compiler-rt
clang -march=morello+c64 -mabi=purecap \
    -c llvm-project/compiler-rt/lib/crt/crtbegin.c \
    -o llvm/lib/clang/11.0.0/lib/linux/clang_rt.crtbegin-morello.o
clang -march=morello+c64 -mabi=purecap \
    -c llvm-project/compiler-rt/lib/crt/crtend.c \
    -o llvm/lib/clang/11.0.0/lib/linux/clang_rt.crtend-morello.o

_NCORES=$(nproc --all)

# Build musl
cd musl
mkdir -p ../musl-bin
CC=clang ./configure --prefix=$(realpath $(pwd)/../musl-bin) --disable-shared --enable-morello --enable-libshim
make -j$_NCORES
make install

