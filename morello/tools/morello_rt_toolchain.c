/* SPDX-License-Identifier: BSD-3-Clause */
#include <stdio.h>

#define LOG(x)		printf("[Morello_RT_Toolchain]: %s", x)
#define ASSERT(x)	assert(x)

int main(int argc, char *argv[]) {
	FILE *fptr;

	if (argc < 3) {
		LOG("usage: morello_rt_toolchain <arch> <file_path>\n");
		goto out;
	}

	fptr = fopen(argv[2], "w");

	if (fptr == NULL) {
		LOG("incorrect file_path\n");
		goto out;
	}

	fprintf(fptr, "set(CMAKE_SYSTEM_NAME Linux)\n");
	fprintf(fptr, "set(CMAKE_SYSTEM_PROCESSOR %s)\n", argv[1]);
	fprintf(fptr, "set(CMAKE_C_COMPILER_TARGET \"aarch64-linux-gnu -march=morello+c64 -mabi=purecap\")\n");
	fprintf(fptr, "set(CMAKE_C_COMPILER_WORKS 1 CACHE INTERNAL \"\")\n");
	fprintf(fptr, "set(CMAKE_CXX_COMPILER_WORKS 1 CACHE INTERNAL \"\")\n");
	fprintf(fptr, "set(CMAKE_C_COMPILER \"clang\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(CMAKE_CXX_COMPILER \"clang++\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(CMAKE_AR \"llvm-ar\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(CMAKE_RANLIB \"llvm-ranlib\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(CMAKE_NM \"llvm-nm\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(CMAKE_LINKER \"ld.lld\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(CMAKE_OBJDUMP \"llvm-objdump\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(CMAKE_OBJCOPY \"llvm-objcopy\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(LLVM_CONFIG_PATH \"llvm-config\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(CMAKE_EXE_LINKER_FLAGS \"-fuse-ld=lld\" CACHE FILEPATH \"\" FORCE)\n");
	fprintf(fptr, "set(CMAKE_SHARED_LINKER_FLAGS \"-fuse-ld=lld\" CACHE FILEPATH \"\" FORCE)\n");

	fclose(fptr);

out:
	return 0;
}
