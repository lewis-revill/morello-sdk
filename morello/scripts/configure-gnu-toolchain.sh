#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-sdk-versions

CURR_DIR=$(pwd)

get_gnu_submodule() {
	cd ${CURR_DIR}

	echo "gnu toolchain updating progress..."
	
	git submodule update --init --recursive --progress gnu
}

get_gnu_toolchain() {
	cd ${CURR_DIR}/gnu

	git checkout $MORELLO_GNU_VERSION
	
	cd ${CURR_DIR}

	touch ${CURR_DIR}/.gnu-toolchain
}

if [ ! -f "${CURR_DIR}/.gnu-toolchain" ]; then
	get_gnu_submodule
	get_gnu_toolchain
fi
