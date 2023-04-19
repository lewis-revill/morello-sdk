#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-sdk-versions

CURR_DIR=$(pwd)

OPTIONS_MODE="${OPTIONS_MODE:-aarch64}"
BRANCH=
MUSL_DEV_COMMIT=fed6dda4b524188d7f9ad352d921c0b2ba058714

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

if [ "$OPTIONS_MODE" = "aarch64" ]; then
	BRANCH="morello/linux-aarch64-release-$MORELLO_COMPILER_VERSION"
elif [ "$OPTIONS_MODE" = "x86_64" ]; then
	BRANCH="morello/linux-release-$MORELLO_COMPILER_VERSION"
fi

PROJECTS_LIST=( llvm musl )
PROJECTS_SOURCE=( llvm-project )

if [ ! -f "${CURR_DIR}/.llvm-env" ]; then
	for i in "${PROJECTS_LIST[@]}"
	do
		echo "$i updating progress..."
		# Populate repositories
		if [ $i == "llvm" ]; then
			git submodule update --init --recursive --depth 1 --progress $i
		else
			git submodule update --init --recursive --progress $i
		fi
		git submodule update --remote --merge $i
	done

	if [ "$BUILD_LIB" = "on" ]; then
		for i in "${PROJECTS_SOURCE[@]}"
		do
			echo "$i updating progress..."
			# Populate repositories
			git submodule update --init --recursive --depth 1 --progress $i
			git submodule update --remote --merge $i
		done
	fi

	touch ${CURR_DIR}/.llvm-env
fi

# Config Clang
cd ${CURR_DIR}/llvm && \
git remote set-branches origin $BRANCH && \
git fetch --depth 1 origin $BRANCH && \
git checkout $BRANCH

if [ "$BUILD_LIB" = "on" ]; then
	# Config Clang sources to build compiler-rt for Morello
	cd ${CURR_DIR}/llvm-project
	git checkout morello/release-$MORELLO_COMPILER_SOURCE_VERSION
fi

# Config Musl
if [ "$OPTIONS_DEV_MODE" == "off" ]; then
	(cd ${CURR_DIR}/musl; checkout_musl_tag);
else
	(cd ${CURR_DIR}/musl; git checkout morello/master; reset_musl_dev);
	echo "[Experimental Mode ON]";
fi
