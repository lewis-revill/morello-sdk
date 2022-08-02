#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

_NCORES=$(nproc --all)

OUTPUT_DIR="${MORELLO_PROJECTS}/bsp/arm-tf/build/morello/release"

platforms=( soc fvp )

copy_arm_tf_bin() {
	cp "${OUTPUT_DIR}/bl1.bin" "${BSP_HOME}/$1/arm-tf/tf-bl1.bin"
	cp "${OUTPUT_DIR}/bl2.bin" "${BSP_HOME}/$1/arm-tf/tf-bl2.bin"
	cp "${OUTPUT_DIR}/bl31.bin" "${BSP_HOME}/$1/arm-tf/tf-bl31.bin"
	cp "${OUTPUT_DIR}/fdts/morello-$1.dtb" "${BSP_HOME}/$1/arm-tf/morello.dtb"
	cp "${OUTPUT_DIR}/fdts/morello_fw_config.dtb" "${BSP_HOME}/$1/arm-tf/morello_fw_config.dtb"
	cp "${OUTPUT_DIR}/fdts/morello_tb_fw_config.dtb" "${BSP_HOME}/$1/arm-tf/morello_tb_fw_config.dtb"
	cp "${OUTPUT_DIR}/fdts/morello_nt_fw_config.dtb" "${BSP_HOME}/$1/arm-tf/morello_nt_fw_config.dtb"
}

# Create output folders
output=( soc fvp )

for o in "${output[@]}"
do
	mkdir -p ${BSP_HOME}/$o/arm-tf
done

# Build arm-tf
options=(
	--no-print-directory
)

projects=(
	fiptool
	cert_create
)

# Perform a realclean
make "${options}" -C "${MORELLO_PROJECTS}/bsp/arm-tf" realclean

# Build all the projects
for prj in "${projects[@]}"
do
	make "${options}" -C "${MORELLO_PROJECTS}/bsp/arm-tf/tools/$prj"
done

options+=(
	-C "${MORELLO_PROJECTS}/bsp/arm-tf/"
	-j "${_NCORES}"
	ARCH=aarch64
	E=0
	PLAT=morello
	ARM_ROTPK_LOCATION="devel_rsa"
	CREATE_KEYS=1
	GENERATE_COT=1
	MBEDTLS_DIR="${MORELLO_PROJECTS}/bsp/mbedtls"
	ROT_KEY="plat/arm/board/common/rotpk/arm_rotprivk_rsa.pem"
	TRUSTED_BOARD_BOOT=1
	DEBUG=0
	CC=clang
	LD=ld.lld
	CROSS_COMPILE=llvm-
	ENABLE_MORELLO_CAP=1
)

for p in "${platforms[@]}"
do
	options+=(
		TARGET_PLATFORM=$p
	)

	make "${options[@]}" all
	copy_arm_tf_bin $p
done
