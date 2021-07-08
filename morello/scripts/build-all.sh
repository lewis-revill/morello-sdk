#!/usr/bin/env bash

PWD=$(pwd)

# Download LLVM and musl for Morello
${PWD}/scripts/download-llvm-musl.sh

# Build Musl
${PWD}/scripts/build-musl.sh

# Build morello_elf
cd ${PWD}/tools
make

# Build test-app
cd ${PWD}/test-app
make
