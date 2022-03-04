#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-aarch64-versions

CURR_DIR=$(pwd)

MODE="${MODE:-aarch64}"
BRANCH=
MUSL_DEV_COMMIT=165e4eb5f0b8b6a3707771278860f7e518345fd6

reset_musl_dev () {
	if [ ! -z ${MUSL_DEV_COMMIT} ]; then
		git reset --hard ${MUSL_DEV_COMMIT};
	fi
}

checkout_musl_tag () {
	if [ $(git rev-parse --verify morello/release) ]; then
		git checkout morello/release;
	else
		git fetch --all --tags;
		git checkout -b morello/release tags/$MORELLO_MUSL_SOURCE_TAG;
	fi
}

if [ "$MODE" = "aarch64" ]; then
    BRANCH="morello/linux-aarch64-release-$MORELLO_COMPILER_VERSION"
elif [ "$MODE" = "x86_64" ]; then
    BRANCH="morello/baremetal-release-$MORELLO_COMPILER_VERSION"
fi

if [ ! -f "${CURR_DIR}/.llvm-env" ]; then
	# Populate repositories
	git submodule update --init --recursive --progress
	git submodule update --remote --merge

	touch ${CURR_DIR}/.llvm-env
fi

# Config Clang
(cd ${CURR_DIR}/llvm; git checkout $BRANCH)

# Config Clang sources to build compiler-rt for Morello
(cd ${CURR_DIR}/llvm-project; git checkout morello/release-$MORELLO_COMPILER_SOURCE_VERSION)

# Config Musl
if [ "$DEV_MODE" == "off" ]; then
	(cd ${CURR_DIR}/musl; checkout_musl_tag);
else
	(cd ${CURR_DIR}/musl; git checkout morello/master; reset_musl_dev);
	echo "[Experimental Mode ON]";
fi
