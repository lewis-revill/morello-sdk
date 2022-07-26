#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-aarch64-versions

CURR_DIR=$(pwd)

MODE="${MODE:-aarch64}"
BRANCH=
MUSL_DEV_COMMIT=4111f17d06937db9721e86edde0e77de1bd9c3fa

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
	BRANCH_S="morello/linux-aarch64-release-$MORELLO_COMPILER_VERSION"
	BRANCH="morello/baremetal-release-$MORELLO_COMPILER_VERSION"
fi

PROJECTS_LIST=( llvm musl )
PROJECTS_SOURCE=( llvm-project )

if [ ! -f "${CURR_DIR}/.llvm-env" ]; then
	for i in "${PROJECTS_LIST[@]}"
	do
		echo "$i updating progress..."
		# Populate repositories
		git submodule update --init --recursive --progress $i
		git submodule update --remote --merge $i
	done

	if [ "$BUILD_LIB" = "on" ]; then
		for i in "${PROJECTS_SOURCE[@]}"
		do
			echo "$i updating progress..."
			# Populate repositories
			git submodule update --init --recursive --progress $i
			git submodule update --remote --merge $i
		done
	fi

	touch ${CURR_DIR}/.llvm-env
fi

# Config Clang
if [ "$MODE" = "aarch64" ]; then
	cd ${CURR_DIR}/llvm
	git checkout $BRANCH
elif [ "$MODE" = "x86_64" ]; then
	cd ${CURR_DIR}/llvm
	git clean -fd
	git checkout $BRANCH_S
	mkdir -p ${CURR_DIR}/.tmp/aarch64-unknown-linux-musl_purecap
	cp -Rfv ${CURR_DIR}/llvm/lib/clang/13.0.0/lib/aarch64-unknown-linux-musl_purecap/* ${CURR_DIR}/.tmp/aarch64-unknown-linux-musl_purecap
	git checkout $BRANCH
	mv ${CURR_DIR}/.tmp/aarch64-unknown-linux-musl_purecap ${CURR_DIR}/llvm/lib/clang/13.0.0/lib/
	rm ${CURR_DIR}/.tmp -fr
fi

if [ "$BUILD_LIB" = "on" ]; then
	# Config Clang sources to build compiler-rt for Morello
	cd ${CURR_DIR}/llvm-project
	git checkout morello/release-$MORELLO_COMPILER_SOURCE_VERSION
fi

# Config Musl
if [ "$DEV_MODE" == "off" ]; then
	(cd ${CURR_DIR}/musl; checkout_musl_tag);
else
	(cd ${CURR_DIR}/musl; git checkout morello/master; reset_musl_dev);
	echo "[Experimental Mode ON]";
fi
