#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

create_morello_structure() {
	mkdir -p ${MORELLO_HOME}
	mkdir -p ${MORELLO_HOME}/env
}

clean_morello_structure() {
	rm -fr ${MORELLO_HOME}
}

copy_morello_toolchain() {
	local projects=( bin examples llvm )

	for p in "${projects[@]}"
	do
		cp -Rf ${MORELLO_AARCH64_HOME}/$p ${MORELLO_HOME}/$p
	done

	cp -Rf ${MORELLO_AARCH64_HOME}/musl-bin ${MORELLO_HOME}/musl
	cp -Rf ${MORELLO_AARCH64_HOME}/projects/morello-linux-headers/usr ${MORELLO_HOME}/

	if [ -d "${MORELLO_AARCH64_HOME}/morello-docker" ]; then
		cp -Rf ${MORELLO_AARCH64_HOME}/morello-docker ${MORELLO_HOME}/docker
	fi
}

copy_gnu_toolchain() {
	cp -Rf ${MORELLO_AARCH64_HOME}/gnu/${OPTIONS_MODE}-aarch64-none-linux-gnu ${MORELLO_HOME}/gnu
}

create_morello_env() {
	cp -Rf ${MORELLO_AARCH64_HOME}/env/morello-sdk.template ${MORELLO_HOME}/env/morello-sdk
}

cleanup_morello_env() {
	rm -fr ${MORELLO_HOME}/llvm/.git
}

morello_install() {
	clean_morello_structure

	create_morello_structure

	copy_morello_toolchain

	copy_gnu_toolchain

	create_morello_env

	cleanup_morello_env
}

morello_install $@
