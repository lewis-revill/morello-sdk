#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

MODE="aarch64"
LIBSHIM="--disable-libshim"
DEV_MODE="off"
CURR_DIR=$(pwd)
MORELLO_PROJECTS=$(realpath $(pwd)/projects)
BSP_HOME=$(realpath $(pwd)/bsp)
LINUX_HOME=$(realpath $(pwd)/projects/linux)
KBUILD_OUTPUT=$(realpath $(pwd)/linux-out)
PRJ_BIN=$(realpath $(pwd)/bin)
EXAMPLES_BIN=$(realpath $(pwd)/examples/bin)
MUSL_BIN=$(realpath $(pwd)/musl-bin)
GCC_HOME=$(realpath $(pwd)/gcc)
COMPILER_RT_BIN=$(realpath $(pwd)/compiler_rt-bin)
MORELLO_ROOTFS=$(realpath $(pwd)/morello-rootfs)
MORELLO_TESTING="$MORELLO_ROOTFS/testing"
MORELLO_DOCKER=$(realpath $(pwd)/morello-docker)

if [ -f "/proc/cpuinfo" ]; then
	NCORES=$(grep -c ^processor /proc/cpuinfo)
	_NCORES=$(($NCORES / 2))
else
	_NCORES=1
fi

export MORELLO_PROJECTS
export BSP_HOME
export LINUX_HOME
export KBUILD_OUTPUT
export PRJ_BIN
export EXAMPLES_BIN
export MUSL_BIN
export GCC_HOME
export COMPILER_RT_BIN
export MORELLO_ROOTFS
export MORELLO_TESTING
export MORELLO_DOCKER
export MODE
export LIBSHIM
export DEV_MODE
export _NCORES

# Optional configuration paramenters
OPTIONS_FIRMWARE="off"
OPTIONS_LINUX="off"
OPTIONS_C_APPS="off"
OPTIONS_ROOTFS="off"
OPTIONS_DOCKER="off"
OPTIONS_BUILD_LIB="off"

export OPTIONS_FIRMWARE
export OPTIONS_LINUX
export OPTIONS_C_APPS
export OPTIONS_ROOTFS
export OPTIONS_DOCKER
export OPTIONS_BUILD_LIB

help () {
cat <<EOF
Usage: $0 [options]

OPTIONS:
  --aarch64           build on an aarch64 host [DEFAULT]
  --x86_64            build on an x86_64 host
  --enable-libshim    enable libshim in musl
  --dev               experimental mode (allows to use more recent versions of musl)
  --firmware          generate the firmware for Morello
  --linux             builds linux for Morello
  --c-apps            builds example c applications for Morello
  --rootfs            builds the rootfs for Morello
  --docker            generate a busybox based docker image
  --build-lib         build libraries from source (e.g. compiler_rt, crtobjects...)
  --help              this help message
EOF
exit 0
}

main () {
	set +x

	for arg ; do
	case $arg in
		--aarch64) MODE="aarch64" ;;
		--x86_64) MODE="x86_64" ;;
		--enable-libshim) LIBSHIM="--enable-libshim" ;;
		--dev) DEV_MODE="on" ;;
		--firmware) OPTIONS_FIRMWARE="on" ;;
		--linux) OPTIONS_LINUX="on" ;;
		--c-apps) OPTIONS_C_APPS="on" ;;
		--rootfs) OPTIONS_ROOTFS="on" ;;
		--docker) OPTIONS_DOCKER="on";;
		--build-lib) OPTIONS_BUILD_LIB="on";;
		--help|-h) help ;;
	esac
	done

	if [ "$MODE" = "aarch64" -a $(uname -m) != "aarch64" ]; then
		echo "ERROR: attempting an aarch64 cross build NOT on an arm cpu";
		exit 1
	fi

	# Cleanup old files
	rm -fr ${MORELLO_ROOTFS} ${MUSL_BIN} ${COMPILER_RT_BIN} ${PRJ_BIN} ${EXAMPLES_BIN} ${BSP_HOME}

	echo "RootFS: ${MORELLO_ROOTFS}"
	echo "Testing: ${MORELLO_TESTING}"

	# Create required directories
	mkdir -p ${MORELLO_ROOTFS} && mkdir -p ${MORELLO_TESTING} && mkdir -p ${GCC_HOME}

	# Configure LLVM and musl for Morello
	${CURR_DIR}/scripts/configure-llvm-musl.sh

	# Build morello_elf
	cd ${CURR_DIR}/tools
	make
	cd ${CURR_DIR}

	# Build Musl
	${CURR_DIR}/scripts/build-musl.sh

	if [ "$OPTIONS_FIRMWARE" = "on" ]; then
		# Configure GCC Toolchain
		${CURR_DIR}/scripts/configure-gcc-toolchain.sh

		# Configure Firmware for Morello
		${CURR_DIR}/scripts/configure-firmware.sh

		# Build SCP
		${CURR_DIR}/scripts/build-scp.sh

		# Build UEFI (UEFI must be built before then arm-tf)
		${CURR_DIR}/scripts/build-uefi.sh

		# Build ARM-TF
		${CURR_DIR}/scripts/build-arm-tf.sh

		# Generate Firmware
		${CURR_DIR}/scripts/generate-firmware.sh

		# Build GRUB
		${CURR_DIR}/scripts/build-grub.sh
	fi

	if [ "$OPTIONS_LINUX" = "on" ]; then
		# Build Linux
		${CURR_DIR}/scripts/build-linux.sh
	fi

	if [ "$OPTIONS_BUILD_LIB" = "on" ]; then
		# Build Libraries
		${CURR_DIR}/scripts/build-libraries.sh
	fi

	if [ "$OPTIONS_C_APPS" = "on" ]; then
		# Create examples/bin
		mkdir -p ${EXAMPLES_BIN}

		# Build test-app
		cd ${CURR_DIR}/examples/test-app
		make

		# Build morello-heap-app
		cd ${CURR_DIR}/examples/morello-heap-app
		make

		# Build morello-stack-app
		cd ${CURR_DIR}/examples/morello-stack-app
		make

		# Build morello-pthread-app
		cd ${CURR_DIR}/examples/morello-pthread-app
		make

		# Build morello-auxv-app
		cd ${CURR_DIR}/examples/morello-auxv-app
		make
	fi

	if [ "$OPTIONS_ROOTFS" = "on" ]; then
		# Build PCuABI busybox
		${CURR_DIR}/scripts/build-busybox.sh
	fi

	if [ "$OPTIONS_DOCKER" = "on" ]; then
		# Build PCuABI busybox based docker image
		${CURR_DIR}/scripts/build-busybox-docker.sh
	fi
}

time main $@
