#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

MORELLO_ROOTFS_CFG=${MORELLO_PROJECTS}/config/morello_busybox_config
MORELLO_ROOTFS_SRC=${MORELLO_PROJECTS}/morello-busybox

_NCORES=$(nproc --all)

# Build morello-busybox
cp ${MORELLO_ROOTFS_CFG} ${MORELLO_ROOTFS_SRC}/.config

cd ${MORELLO_ROOTFS_SRC}

# Locally unset KBUILD_OUTPUT as this one is not being used by busybox build
# and otherwise it messes things up
ALTER_ENV="env -u KBUILD_OUTPUT"

make clean && $ALTER_ENV make -j$_NCORES && $ALTER_ENV make CONFIG_PREFIX=${MORELLO_ROOTFS} install

