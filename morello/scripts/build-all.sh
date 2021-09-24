#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

MODE="native"

help () {
cat <<EOF
Usage: $0 [options]

OPTIONS:
  --native   build on an aarch64 host [DEFAULT]
  --cross    build on an x86_64 host
EOF
exit 0
}

for arg ; do
case $arg in
    --native) MODE="native" ;;
    --cross) MODE="cross" ;;
    --help|-h) help ;;
esac
done

if [ "$MODE" = "native" -a $(uname -m) != "aarch64" ]; then
    echo "ERROR: attempting a native build NOT on an arm cpu";
    exit 1
fi

CURR_DIR=$(pwd)
export MODE

# Configure LLVM and musl for Morello
${CURR_DIR}/scripts/configure-llvm-musl.sh

# Build Musl
${CURR_DIR}/scripts/build-musl.sh

# Build morello_elf
cd ${CURR_DIR}/tools
make

# Build test-app
cd ${CURR_DIR}/test-app
make
