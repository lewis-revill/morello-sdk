#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

_NCORES=$(nproc --all)

mkdir -p ${MUSL_BIN}

# Build musl
cd musl
CC=clang ./configure \
	--disable-shared \
	--enable-morello \
	${LIBSHIM} \
	--target=aarch64-linux-gnu \
	--prefix=${MUSL_BIN}

if [ "$?" != 0 ]; then
    exit 1
else
    make -j$_NCORES
    make install
fi

