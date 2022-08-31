#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

_NCORES=$(nproc --all)
MORELLO_CONFIG="morello_transitional_pcuabi_defconfig"
ARCH=arm64
CC=clang
CROSS_COMPILE=aarch64-linux-gnu-
LLVM=1

export _NCORES
export MORELLO_CONFIG
export ARCH
export CC
export CROSS_COMPILE
export LLVM

linux_clean() {
    make mrproper && make clean
}

linux_build() {
    mkdir -p ${KBUILD_OUTPUT}

    # Build linux for Morello
    cd ${LINUX_HOME}
    make $MORELLO_CONFIG && make -j$_NCORES -s
}

linux_build $@