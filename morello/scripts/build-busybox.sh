#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

MORELLO_ROOTFS_CFG=${MORELLO_PROJECTS}/config/morello_busybox_config
MORELLO_ROOTFS_SRC=${MORELLO_PROJECTS}/morello-busybox

_NCORES=$(nproc --all)

mkdir -p ${MORELLO_ROOTFS}

# Build morello-busybox
cp ${MORELLO_ROOTFS_CFG} ${MORELLO_ROOTFS_SRC}/.config

cd ${MORELLO_ROOTFS_SRC}
make clean && make -j$_NCORES && make CONFIG_PREFIX=${MORELLO_ROOTFS} install

