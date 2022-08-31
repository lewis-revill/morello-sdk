#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

platforms=( soc fvp )

copy_grub_objects() {
	for p in "${platforms[@]}"
	do
		cp ${BSP_HOME}/out/grub/grub.efi ${BSP_HOME}/$p/grub
		cp ${MORELLO_PROJECTS}/config/grub_$p.cfg ${BSP_HOME}/$p/grub
		cp ${BSP_HOME}/$p/grub/* ${BSP_HOME}/firmware/$p/
	done
}

grub_build() {
	local _NCORES=$(nproc --all)

	local MODULES=(
		boot
		chain
		configfile
		ext2
		fat
		gzio
		help
		linux
		loadenv
		lsefi
		normal
		ntfs
		ntfscomp
		part_gpt
		part_msdos
		progress
		read
		search
		search_fs_file
		search_fs_uuid
		search_label
		terminal
		terminfo
	)

	export PYTHON="python3"

	output=( soc fvp out )

	for o in "${output[@]}"
	do
		mkdir -p ${BSP_HOME}/$o/grub
	done

	GRUB_HOME=${MORELLO_PROJECTS}/bsp/grub/build

	mkdir -p ${GRUB_HOME}
	cd ${GRUB_HOME}

	env -C "${MORELLO_PROJECTS}/bsp/grub" ./bootstrap

	${MORELLO_PROJECTS}/bsp/grub/configure \
		TARGET_CC="${GCC_ARM64}gcc" \
		TARGET_OBJCOPY="${GCC_ARM64}objcopy" \
		TARGET_STRIP="${GCC_ARM64}strip" \
		--target=aarch64-linux-gnu \
		--prefix="${GRUB_HOME}/install" \
		--with-platform=efi \
		--enable-dependency-tracking \
		--disable-efiemu \
		--disable-werror \
		--disable-grub-mkfont \
		--disable-grub-themes \
		--disable-grub-mount

	make --no-print-directory -j${_NCORES} install

	echo 'set prefix=($root)/grub/' > "${GRUB_HOME}/embedded.cfg"

	"${GRUB_HOME}/install/bin/grub-mkimage" \
		-c "${GRUB_HOME}/embedded.cfg" \
		-o "${BSP_HOME}/out/grub/grub.efi" \
		-O arm64-efi \
		-p "" \
		"${MODULES[@]}"

	copy_grub_objects
}

grub_build $@