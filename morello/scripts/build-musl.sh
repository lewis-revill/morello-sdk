#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

musl_clean() {
	rm -fr ${MUSL_BIN}
}

musl_build() {
	local _NCORES=$(nproc --all)

	mkdir -p ${MUSL_BIN}

	# Build musl
	cd musl
	CC=clang ./configure \
		--disable-shared \
		--enable-morello \
		${OPTIONS_LIBSHIM} \
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