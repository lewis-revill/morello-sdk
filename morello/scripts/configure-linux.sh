#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

source ./env/morello-pcuabi-env-versions

CURR_DIR=$(pwd)

submodule_update() {
	echo "$1 updating progress..."
	# Populate repositories
	git submodule update --init --recursive --progress $1
	git submodule update --remote --merge $1
}

submodule_update_projects() {
	submodule_update projects/$1

	cd projects/$1
	git checkout -b morello/master
	cd ${CURR_DIR}
}

PROJECTS_LIST=( linux )

if [ ! -f "${CURR_DIR}/.linux-env" ]; then
	for i in "${PROJECTS_LIST[@]}"
	do
		submodule_update_projects $i
	done

	touch ${CURR_DIR}/.linux-env
fi
