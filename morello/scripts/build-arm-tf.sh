#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

_NCORES=$(nproc --all)

OUTPUT_DIR="${MORELLO_PROJECTS}/bsp/arm-tf/build/morello/release"

copy_arm_tf_bin() {
	cp "${OUTPUT_DIR}/bl1.bin" "${BSP_HOME}/$1/arm-tf/tf-bl1.bin"
	cp "${OUTPUT_DIR}/bl2.bin" "${BSP_HOME}/$1/arm-tf/tf-bl2.bin"
	cp "${OUTPUT_DIR}/bl31.bin" "${BSP_HOME}/$1/arm-tf/tf-bl31.bin"
	cp "${OUTPUT_DIR}/fip.bin" "${BSP_HOME}/$1/arm-tf/fip.bin"
	cp "${OUTPUT_DIR}/fdts/morello-$1.dtb" "${BSP_HOME}/$1/arm-tf/morello.dtb"
	cp "${OUTPUT_DIR}/fdts/morello_fw_config.dtb" "${BSP_HOME}/$1/arm-tf/morello_fw_config.dtb"
	cp "${OUTPUT_DIR}/fdts/morello_tb_fw_config.dtb" "${BSP_HOME}/$1/arm-tf/morello_tb_fw_config.dtb"
	cp "${OUTPUT_DIR}/fdts/morello_nt_fw_config.dtb" "${BSP_HOME}/$1/arm-tf/morello_nt_fw_config.dtb"
}

arm_tf_build() {
	# Supported Platforms
	local platforms=( soc fvp )

	# Create output folders
	local output=( soc fvp )

	for o in "${output[@]}"
	do
		mkdir -p ${BSP_HOME}/$o/arm-tf
	done

	# Build arm-tf
	local options=(
		--no-print-directory
	)

	local projects=(
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

	local options+=(
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
		local options_plat=(
			TARGET_PLATFORM="${p}"
			BL33="${BSP_HOME}/${p}/uefi/BL33_AP_UEFI.fd"
		)

		make "${options[@]}" "${options_plat[@]}" all fip
		copy_arm_tf_bin $p
	done
}

arm_tf_build $@