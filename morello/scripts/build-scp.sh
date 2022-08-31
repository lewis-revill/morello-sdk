#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

scp_output_generate() {
	# Create output folders
	local output=( soc fvp out )

	for o in "${output[@]}"
	do
		mkdir -p ${BSP_HOME}/$o/scp
	done
}

scp_platforms_generate() {
	local platforms=( soc fvp )

	# Copy firmware across
	for p in "${platforms[@]}"
	do
		cp "${BSP_HOME}/out/scp/scp_romfw/bin/morello-bl1.bin" "${BSP_HOME}/$p/scp/scp-rom.bin"
		cp "${BSP_HOME}/out/scp/mcp_romfw/bin/morello-mcp-bl1.bin" "${BSP_HOME}/$p/scp/mcp-rom.bin"
		cp "${BSP_HOME}/out/scp/scp_ramfw_$p/bin/morello-$p-bl2.bin" "${BSP_HOME}/$p/scp/scp-ram.bin"
		cp "${BSP_HOME}/out/scp/mcp_ramfw_$p/bin/morello-$p-mcp-bl2.bin" "${BSP_HOME}/$p/scp/mcp-ram.bin"
	done
}

scp_build() {
	local GCC_ARM32_PATH=$(which ${GCC_ARM32}gcc)
	local OBJCOPY_ARM32_PATH=$(which ${GCC_ARM32}objcopy)

	local _NCORES=$(nproc --all)

	scp_output_generate

	# Build scp
	options=(
		-S "${MORELLO_PROJECTS}/bsp/scp"
		-DSCP_TOOLCHAIN:STRING="GNU"
		-DCMAKE_C_COMPILER="${GCC_ARM32_PATH}"
		-DCMAKE_ASM_COMPILER="${GCC_ARM32_PATH}"
		-DCMAKE_OBJCOPY="${OBJCOPY_ARM32_PATH}"
		-DCMAKE_BUILD_TYPE=Release
		-DSCP_LOG_LEVEL=INFO
	)

	projects=(
		mcp_romfw
		scp_romfw
		scp_ramfw_fvp
		mcp_ramfw_fvp
		scp_ramfw_soc
		mcp_ramfw_soc
	)

	for fw in "${projects[@]}"
	do
		options+=(
			-B "${BSP_HOME}/out/scp/$fw"
			-DSCP_FIRMWARE_SOURCE_DIR:PATH="morello/$fw"
		)

		cmake "${options[@]}"
		cmake --build "${BSP_HOME}/out/scp/$fw" --parallel "$_NCORES"
	done

	scp_platforms_generate
}

scp_build $@