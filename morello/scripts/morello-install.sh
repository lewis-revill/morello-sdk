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
	cp -Rf ${MORELLO_AARCH64_HOME}/morello-docker ${MORELLO_HOME}/docker
}

create_morello_env() {
	cp -Rf ${MORELLO_AARCH64_HOME}/env/morello-pcuabi-env.template ${MORELLO_HOME}/env/morello-pcuabi-env
}

cleanup_morello_env() {
	rm -fr ${MORELLO_HOME}/llvm/.git
}

morello_install() {
	if [ "$EUID" -ne 0 ]; then
		echo "[DO NOT USE --install OPTION OUTSIDE OF A CONTAINER]"
		exit
	fi

	clean_morello_structure

	create_morello_structure

	copy_morello_toolchain

	create_morello_env

	cleanup_morello_env
}

morello_install $@
