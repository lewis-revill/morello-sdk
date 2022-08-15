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

mkdir -p ${KBUILD_OUTPUT}

cd ${LINUX_HOME}

# Build kselftest
make -j1 -C tools/testing/selftests/ TARGETS=arm64 ARM64_SUBTARGETS=morello -s
