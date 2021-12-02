#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-aarch64-versions

CURR_DIR=$(pwd)

MODE="${MODE:-aarch64}"
BRANCH=

if [ "$MODE" = "aarch64" ]; then
    BRANCH="morello/linux-aarch64-release-$MORELLO_COMPILER_VERSION"
elif [ "$MODE" = "x86_64" ]; then
    BRANCH="morello/baremetal-release-$MORELLO_COMPILER_VERSION"
fi

# Populate repositories
git submodule update --init --recursive --progress
git submodule update --remote --merge

# Config Clang
(cd ${CURR_DIR}/llvm; git checkout $BRANCH)

# Config Clang sources to build compiler-rt for Morello
(cd ${CURR_DIR}/llvm-project; git checkout morello/release-$MORELLO_COMPILER_SOURCE_VERSION)

# Config Musl
(cd ${CURR_DIR}/musl; git fetch --all --tags; git checkout -b morello/release tags/$MORELLO_MUSL_SOURCE_TAG)
