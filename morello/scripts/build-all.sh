#!/usr/bin/env bash

CURR_DIR=$(pwd)

# Download LLVM and musl for Morello
${CURR_DIR}/scripts/download-llvm-musl.sh

# Build Musl
${CURR_DIR}/scripts/build-musl.sh

# Build morello_elf
cd ${CURR_DIR}/tools
make

# Build test-app
cd ${CURR_DIR}/test-app
make
