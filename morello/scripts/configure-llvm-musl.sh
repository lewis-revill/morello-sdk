#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-aarch64-versions

CURR_DIR=$(pwd)

MODE="${MODE:-native}"
BRANCH=

if [ "$MODE" = "native" ]; then
    BRANCH="morello/linux-aarch64-release-$MORELLO_COMPILER_VERSION"
elif [ "$MODE" = "cross" ]; then
    BRANCH="morello/baremetal-release-$MORELLO_COMPILER_VERSION"
fi

# Populate repositories
git submodule update --init --recursive --progress
git submodule update --remote --merge

# Config Clang
(cd ${CURR_DIR}/llvm; git checkout $BRANCH)

# Config Clang sources to build compiler-rt for Morello
(cd ${CURR_DIR}/llvm-project; git checkout morello/release-$MORELLO_COMPILER_VERSION)

# Config Musl
(cd ${CURR_DIR}/musl; git checkout morello/master)
