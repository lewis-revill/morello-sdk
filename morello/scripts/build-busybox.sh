#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

busybox_clean() {
    make clean
}

busybox_build() {
    local MORELLO_ROOTFS_CFG=${MORELLO_PROJECTS}/config/morello_busybox_config
    local MORELLO_ROOTFS_SRC=${MORELLO_PROJECTS}/morello-busybox

    local _NCORES=$(nproc --all)

    # Build morello-busybox
    cp ${MORELLO_ROOTFS_CFG} ${MORELLO_ROOTFS_SRC}/.config

    cd ${MORELLO_ROOTFS_SRC}

    # Locally unset KBUILD_OUTPUT as this one is not being used by busybox build
    # and otherwise it messes things up
    local ALTER_ENV="env -u KBUILD_OUTPUT"

    $ALTER_ENV make -j$_NCORES && $ALTER_ENV make CONFIG_PREFIX=${MORELLO_ROOTFS} install
}

busybox_build $@