#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

FIPTOOL_HOME="${MORELLO_PROJECTS}/bsp/arm-tf/tools/fiptool"

export PATH=$FIPTOOL_HOME:$PATH

mkdir -p "${BSP_HOME}/firmware"

output=( soc fvp )

for o in "${output[@]}"
do
	mkdir -p "${BSP_HOME}/firmware/$o"

	fiptool create --scp-fw "${BSP_HOME}/$o/scp/scp-ram.bin" \
		"${BSP_HOME}/$o/scp/scp_fw.bin"

	fiptool create \
		--blob uuid=54464222-a4cf-4bf8-b1b6-cee7dade539e,file="${BSP_HOME}/$o/scp/mcp-ram.bin" \
		"${BSP_HOME}/$o/scp/mcp_fw.bin"

	install --mode=644 "${BSP_HOME}/$o/scp/scp_fw.bin" "${BSP_HOME}/firmware/$o/scp_fw.bin"
	install --mode=644 "${BSP_HOME}/$o/scp/mcp_fw.bin" "${BSP_HOME}/firmware/$o/mcp_fw.bin"
	install --mode=644 "${BSP_HOME}/$o/arm-tf/fip.bin" "${BSP_HOME}/firmware/$o/fip.bin"

	if [ "${o}" == "fvp" ]; then
		install --mode=644 "${BSP_HOME}/$o/scp/scp-rom.bin" "${BSP_HOME}/firmware/$o/scp_romfw.bin"
		install --mode=644 "${BSP_HOME}/$o/scp/mcp-rom.bin" "${BSP_HOME}/firmware/$o/mcp_romfw.bin"
		install --mode=644 "${BSP_HOME}/$o/arm-tf/tf-bl1.bin" "${BSP_HOME}/firmware/$o/tf-bl1.bin"
	fi

done
