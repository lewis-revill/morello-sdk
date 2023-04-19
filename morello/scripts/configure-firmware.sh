#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-sdk-versions

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

generate_bsp_home() {
	local PLATFORMS=( fvp soc out )

	for i in "${PLATFORMS[@]}"
	do
		mkdir -p $BSP_HOME/$i
	done
}

PROJECTS_BSP_OPEN=( grub )
PROJECTS_BSP_OPEN_HASH=( a53e530f8ad3770c3b03c208c08ae4162f68e3b1 )
INDEX=0

if [ ! -f "${CURR_DIR}/.firmware-env" ]; then
	for i in "${PROJECTS_BSP_OPEN[@]}"
	do
		submodule_update_open $i ${PROJECTS_BSP_OPEN_HASH[$INDEX]}
		let INDEX++
	done

	touch ${CURR_DIR}/.firmware-env
fi

generate_bsp_home
