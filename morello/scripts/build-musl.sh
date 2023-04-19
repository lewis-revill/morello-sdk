#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

musl_clean() {
	rm -fr ${MUSL_BIN}
}

musl_build() {
	local _NCORES=$(nproc --all)

	if [ "$OPTIONS_CLEAN" = "on" ]; then
		musl_clean
	fi

	mkdir -p ${MUSL_BIN}

	# Build musl
	cd musl
	CC=clang ./configure \
		--enable-morello \
		--target=aarch64-linux-musl_purecap \
		--prefix=${MUSL_BIN}

	if [ "$?" != 0 ]; then
		exit 1
	else
		make -j$_NCORES
		make install
	fi
}

musl_build $@
