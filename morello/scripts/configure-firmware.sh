#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-aarch64-versions

CURR_DIR=$(pwd)

submodule_update() {
	echo "$1 updating progress..."
	# Populate repositories
	git submodule update --init --recursive --progress $1
	git submodule update --remote --merge $1
}

submodule_update_bsp() {
	submodule_update projects/bsp/$1

	cd projects/bsp/$1
	git checkout morello/release-$2
	cd ${CURR_DIR}
}

submodule_update_open() {
	submodule_update projects/bsp/$1

	cd projects/bsp/$1
	git checkout master
	git reset --hard $2
	cd ${CURR_DIR}
}

submodule_update_projects() {
	submodule_update projects/$1

	cd projects/$1
	git checkout -b morello/master origin/master
	cd ${CURR_DIR}
}

generate_bsp_home() {
	local PLATFORMS=( fvp soc out )

	for i in "${PLATFORMS[@]}"
	do
		mkdir -p $BSP_HOME/$i
	done
}

PROJECTS_LIST=( linux )
PROJECTS_BSP_LIST=( arm-tf scp uefi edk2-platforms )
PROJECTS_BSP_OPEN=( grub mbedtls acpica edk2-non-osi )
PROJECTS_BSP_OPEN_HASH=( a53e530f8ad3770c3b03c208c08ae4162f68e3b1 523f0554b6cdc7ace5d360885c3f5bbcc73ec0e8 HEAD HEAD )
INDEX=0

if [ ! -f "${CURR_DIR}/.firmware-env" ]; then
	for i in "${PROJECTS_BSP_LIST[@]}"
	do
		submodule_update_bsp $i $MORELLO_FIRMWARE_VERSION
	done

	for i in "${PROJECTS_BSP_OPEN[@]}"
	do
		submodule_update_open $i ${PROJECTS_BSP_OPEN_HASH[$INDEX]}
		let INDEX++
	done

	for i in "${PROJECTS_LIST[@]}"
	do
		submodule_update_projects $i
	done

	touch ${CURR_DIR}/.firmware-env
fi

generate_bsp_home
