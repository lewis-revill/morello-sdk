#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

CURR_DIR=$(pwd)

get_gcc_toolchain() {
	_ARCH="$1"
	_GCC_ARM="gcc-arm-11.2-2022.02-$_ARCH-arm-none-eabi.tar.xz"
	GCC_ARM="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/$_GCC_ARM"
	_GCC_ARM64="gcc-arm-11.2-2022.02-$_ARCH-aarch64-none-elf.tar.xz"
	GCC_ARM64="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/$_GCC_ARM64"

	cd ${GCC_HOME}
	wget $GCC_ARM
	wget $GCC_ARM64

	tar -xf $_GCC_ARM
	tar -xf $_GCC_ARM64

	rm $_GCC_ARM
	rm $_GCC_ARM64

	cd ${CURR_DIR}

	touch ${CURR_DIR}/.gcc-toolchain
}

if [ ! -f "${CURR_DIR}/.gcc-toolchain" ]; then
	get_gcc_toolchain $OPTIONS_MODE
fi
