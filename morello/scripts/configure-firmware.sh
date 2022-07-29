#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-aarch64-versions

CURR_DIR=$(pwd)

submodule_update() {
	echo "$1 updating progress..."
	# Populate repositories
	git submodule update --init --recursive --progress projects/bsp/$1
	git submodule update --remote --merge projects/bsp/$1
}

submodule_update_morello() {
	submodule_update $1

	cd projects/bsp/$1
	git checkout -b morello/release-$2 origin/morello/release-$2
	cd ${CURR_DIR}
}

submodule_update_open() {
	submodule_update $1

	cd projects/bsp/$1
	git checkout -b morello/master origin/master
	git reset --hard $2
	cd ${CURR_DIR}
}

PROJECTS_LIST=( arm-tf scp uefi )
PROJECTS_OPEN=( grub mbedtls )
PROJECTS_OPEN_HASH=( a53e530f8ad3770c3b03c208c08ae4162f68e3b1 523f0554b6cdc7ace5d360885c3f5bbcc73ec0e8 )
INDEX=0

if [ ! -f "${CURR_DIR}/.firmware-env" ]; then
	for i in "${PROJECTS_LIST[@]}"
	do
		submodule_update_morello $i $MORELLO_FIRMWARE_VERSION
	done

	for i in "${PROJECTS_OPEN[@]}"
	do
		submodule_update_open $i ${PROJECTS_OPEN_HASH[$INDEX]}
		let INDEX++
	done

	touch ${CURR_DIR}/.firmware-env
fi

