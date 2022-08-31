#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

export CLANG35_BIN="$(dirname $(which clang))/"
export CLANG35_AARCH64_PREFIX="llvm-"
export GCC5_AARCH64_PREFIX="${GCC_ARM64}"
export IASL_PREFIX="${MORELLO_PROJECTS}/bsp/acpica/generate/unix/bin/"
export PACKAGES_PATH="${MORELLO_PROJECTS}/bsp/edk2-platforms:${MORELLO_PROJECTS}/bsp/edk2-non-osi"
export PYTHON_COMMAND="python3"

uefi_output_generate() {
	local platforms=( Soc Fvp )

	# Create output folders
	output=( soc fvp out )

	for o in "${output[@]}"
	do
		mkdir -p ${BSP_HOME}/$o/uefi
	done
}

uefi_build() {
	local _NCORES=$(nproc --all)
	local platforms=( Soc Fvp )

	uefi_output_generate

	# Build uefi
	options=(
		-a AARCH64
		-s
		-b RELEASE
		-D ENABLE_MORELLO_CAP
		-t CLANG35
	)

	# Make acpica and BaseTools
	make -C "${MORELLO_PROJECTS}/bsp/acpica" -j${_NCORES} iasl
	make -C "${MORELLO_PROJECTS}/bsp/uefi/BaseTools" -j${_NCORES}

	cd "${MORELLO_PROJECTS}/bsp/uefi/"
	source ./edksetup.sh --reconfig

	for p in "${platforms[@]}"
	do
		options_plat=(
			-p "${MORELLO_PROJECTS}/bsp/edk2-platforms/Platform/ARM/Morello/MorelloPlatform$p.dsc"
		)

		BaseTools/BinWrappers/PosixLike/build "${options[@]}" "${options_plat[@]}"

		if [ "$p" == "Fvp" ]; then
			cp "${MORELLO_PROJECTS}/bsp/uefi/Build/morellofvp/RELEASE_CLANG35/FV/BL33_AP_UEFI.fd" "${BSP_HOME}/fvp/uefi"
		else
			cp "${MORELLO_PROJECTS}/bsp/uefi/Build/morellosoc/RELEASE_CLANG35/FV/BL33_AP_UEFI.fd" "${BSP_HOME}/soc/uefi"
		fi
	done
}

uefi_build $@