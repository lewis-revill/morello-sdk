#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

MORELLO_AARCH64_HOME=$(realpath $(pwd))
MORELLO_PROJECTS="${MORELLO_AARCH64_HOME}/projects"
BSP_HOME="${MORELLO_AARCH64_HOME}/bsp"
LINUX_HOME="${MORELLO_AARCH64_HOME}/projects/linux"
KBUILD_OUTPUT="${MORELLO_AARCH64_HOME}/linux-out"
PRJ_BIN="${MORELLO_AARCH64_HOME}/bin"
EXAMPLES_BIN="${MORELLO_AARCH64_HOME}/examples/bin"
MUSL_BIN="${MORELLO_AARCH64_HOME}/musl-bin"
GCC_HOME="${MORELLO_AARCH64_HOME}/gcc"
COMPILER_RT_BIN="${MORELLO_AARCH64_HOME}/compiler_rt-bin"
MORELLO_ROOTFS="${MORELLO_AARCH64_HOME}/morello-rootfs"
MORELLO_TESTING="${MORELLO_ROOTFS}/testing"
MORELLO_DOCKER="${MORELLO_AARCH64_HOME}/morello-docker"
MORELLO_HOME="/morello"

if [ -f "/proc/cpuinfo" ]; then
	NCORES=$(grep -c ^processor /proc/cpuinfo)
	_NCORES=$(($NCORES / 2))
else
	_NCORES=1
fi

export MORELLO_AARCH64_HOME
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
export _NCORES
export MORELLO_HOME

# Optional configuration paramenters
OPTIONS_MODE="aarch64"
OPTIONS_FIRMWARE="off"
OPTIONS_LINUX="off"
OPTIONS_KSELFTEST="off"
OPTIONS_C_APPS="off"
OPTIONS_ROOTFS="off"
OPTIONS_DOCKER="off"
OPTIONS_BUILD_LIB="off"
OPTIONS_LIBSHIM="--disable-libshim"
OPTIONS_DEV_MODE="off"
OPTIONS_ENV_INSTALL="off"

export OPTIONS_MODE
export OPTIONS_FIRMWARE
export OPTIONS_LINUX
export OPTIONS_KSELFTEST
export OPTIONS_C_APPS
export OPTIONS_ROOTFS
export OPTIONS_DOCKER
export OPTIONS_BUILD_LIB
export OPTIONS_LIBSHIM
export OPTIONS_DEV_MODE
export OPTIONS_ENV_INSTALL

help () {
cat <<EOF
Usage: $0 [options]

OPTIONS:
[ARCH]:
  --aarch64           build on an aarch64 host [DEFAULT]
  --x86_64            build on an x86_64 host

[LIBC OPTIONS]:
  --enable-libshim    enable libshim in musl
  --dev               experimental mode (allows to use more recent versions of musl)

[MODULES]:
  --firmware          generate the firmware for Morello
  --linux             builds linux for Morello
  --kselftest         builds kselftest for Morello
  --c-apps            builds example c applications for Morello
  --rootfs            builds the rootfs for Morello
  --docker            generate a busybox based docker image
  --build-lib         build libraries from source (e.g. compiler_rt, crtobjects...)

  --install           [DO NOT USE THIS OPTION OUTSIDE OF A CONTAINER]

  --help              this help message
EOF
exit 0
}

main () {
	set +x

	for arg ; do
	case $arg in
		--aarch64) OPTIONS_MODE="aarch64" ;;
		--x86_64) OPTIONS_MODE="x86_64" ;;
		--enable-libshim) OPTIONS_LIBSHIM="--enable-libshim" ;;
		--dev) OPTIONS_DEV_MODE="on" ;;
		--firmware) OPTIONS_FIRMWARE="on" ;;
		--linux) OPTIONS_LINUX="on" ;;
		--kselftest) OPTIONS_KSELFTEST="on" ;;
		--c-apps) OPTIONS_C_APPS="on" ;;
		--rootfs) OPTIONS_ROOTFS="on" ;;
		--docker) OPTIONS_DOCKER="on";;
		--build-lib) OPTIONS_BUILD_LIB="on";;
		--install) OPTIONS_INSTALL="on" ;;
		--help|-h) help ;;
	esac
	done

	if [ "$OPTIONS_MODE" = "aarch64" -a $(uname -m) != "aarch64" ]; then
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
	${MORELLO_AARCH64_HOME}/scripts/configure-llvm-musl.sh

	# Build morello_elf
	cd ${MORELLO_AARCH64_HOME}/tools
	make
	cd ${MORELLO_AARCH64_HOME}

	# Build Musl
	${MORELLO_AARCH64_HOME}/scripts/build-musl.sh

	if [ "$OPTIONS_FIRMWARE" = "on" ]; then
		# Configure GCC Toolchain
		${MORELLO_AARCH64_HOME}/scripts/configure-gcc-toolchain.sh

		# Configure Firmware for Morello
		${MORELLO_AARCH64_HOME}/scripts/configure-firmware.sh

		# Build SCP
		${MORELLO_AARCH64_HOME}/scripts/build-scp.sh

		# Build UEFI (UEFI must be built before then arm-tf)
		${MORELLO_AARCH64_HOME}/scripts/build-uefi.sh

		# Build ARM-TF
		${MORELLO_AARCH64_HOME}/scripts/build-arm-tf.sh

		# Generate Firmware
		${MORELLO_AARCH64_HOME}/scripts/generate-firmware.sh

		# Build GRUB
		${MORELLO_AARCH64_HOME}/scripts/build-grub.sh
	fi

	if [ "$OPTIONS_LINUX" = "on" ]; then
		# Build Linux
		${MORELLO_AARCH64_HOME}/scripts/build-linux.sh
	fi

	if [ "$OPTIONS_KSELFTEST" = "on" ]; then
		# Build Kselftest
		${MORELLO_AARCH64_HOME}/scripts/build-kselftest.sh
	fi

	if [ "$OPTIONS_BUILD_LIB" = "on" ]; then
		# Build Libraries
		${MORELLO_AARCH64_HOME}/scripts/build-libraries.sh
	fi

	if [ "$OPTIONS_C_APPS" = "on" ]; then
		# Create examples/bin
		mkdir -p ${EXAMPLES_BIN}

		# Build test-app
		cd ${MORELLO_AARCH64_HOME}/examples/test-app
		make

		# Build morello-heap-app
		cd ${MORELLO_AARCH64_HOME}/examples/morello-heap-app
		make

		# Build morello-stack-app
		cd ${MORELLO_AARCH64_HOME}/examples/morello-stack-app
		make

		# Build morello-pthread-app
		cd ${MORELLO_AARCH64_HOME}/examples/morello-pthread-app
		make

		# Build morello-auxv-app
		cd ${MORELLO_AARCH64_HOME}/examples/morello-auxv-app
		make
	fi

	if [ "$OPTIONS_ROOTFS" = "on" ]; then
		# Build PCuABI busybox
		${MORELLO_AARCH64_HOME}/scripts/build-busybox.sh
	fi

	if [ "$OPTIONS_DOCKER" = "on" ]; then
		# Build PCuABI busybox based docker image
		${MORELLO_AARCH64_HOME}/scripts/build-busybox-docker.sh
	fi

	if [ "$OPTIONS_INSTALL" = "on" ]; then
		# Install toolchain
		${MORELLO_AARCH64_HOME}/scripts/morello-install.sh
	fi
}

time main $@
