#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

MODE="native"
CURR_DIR=$(pwd)
PRJ_BIN=$(realpath $(pwd)/bin)
MUSL_BIN=$(realpath $(pwd)/musl-bin)
COMPILER_RT_BIN=$(realpath $(pwd)/compiler_rt-bin)

export PRJ_BIN
export MUSL_BIN
export COMPILER_RT_BIN
export MODE

help () {
cat <<EOF
Usage: $0 [options]

OPTIONS:
  --native   build on an aarch64 host [DEFAULT]
  --cross    build on an x86_64 host
EOF
exit 0
}

main () {

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

	# Cleanup old files
	rm -fr ${MUSL_BIN} ${COMPILER_RT_BIN} ${PRJ_BIN}

	# Configure LLVM and musl for Morello
	${CURR_DIR}/scripts/configure-llvm-musl.sh

	# Build morello_elf
	cd ${CURR_DIR}/tools
	make
	cd ${CURR_DIR}

	# Build Musl
	${CURR_DIR}/scripts/build-musl.sh

	# Build Libraries
	${CURR_DIR}/scripts/build-libraries.sh

	# Build test-app
	cd ${CURR_DIR}/test-app
	make

	# Build morello-heap-app
	cd ${CURR_DIR}/morello-heap-app
	make

	# Build morello-stack-app
	cd ${CURR_DIR}/morello-stack-app
	make
}

time main $1
