#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

CLANG_RESOURCE_DIR=$(clang -print-resource-dir)
LLVM_PROJECT=llvm-project

# Build crtbegin and crtend objects
clang --target=aarch64-linux-gnu -march=morello+c64 -mabi=purecap \
    -nostdinc -isystem ${MUSL_BIN}/include \
    -c ${LLVM_PROJECT}/compiler-rt/lib/crt/crtbegin.c \
    -o ${CLANG_RESOURCE_DIR}/lib/linux/clang_rt.crtbegin-morello.o

clang --target=aarch64-linux-gnu -march=morello+c64 -mabi=purecap \
    -nostdinc -isystem ${MUSL_BIN}/include \
    -c ${LLVM_PROJECT}/compiler-rt/lib/crt/crtend.c \
    -o ${CLANG_RESOURCE_DIR}/lib/linux/clang_rt.crtend-morello.o

# Build compiler_rt

COMPILER_RT_TOOLCHAIN=${COMPILER_RT_BIN}/toolchain.cmake

mkdir -p ${COMPILER_RT_BIN}

# Generate toolchain.cmake
morello_rt_toolchain aarch64 ${COMPILER_RT_TOOLCHAIN}

cd ${COMPILER_RT_BIN}

cmake -Wno-dev \
	-DCMAKE_TOOLCHAIN_FILE=${COMPILER_RT_TOOLCHAIN} \
	-DCMAKE_BUILD_TYPE=Release \
	-DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=aarch64-linux-gnu \
	-DCMAKE_C_FLAGS="-nostdinc -isystem ${MUSL_BIN}/include" \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	-DLLVM_TARGETS_TO_BUILD="AArch64" \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_SKIP_BUILD_RPATH=OFF \
	-DCMAKE_INSTALL_RPATH=\$ORIGIN/../lib \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
	-DLLVM_ENABLE_ASSERTIONS=ON \
	-DCOMPILER_RT_BUILD_SANITIZERS=OFF \
	-DCOMPILER_RT_BUILD_XRAY=OFF \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	-DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	-DCOMPILER_RT_BUILD_PROFILE=OFF \
	../${LLVM_PROJECT}/compiler-rt

make clang_rt.builtins-aarch64

mv lib/linux/libclang_rt.builtins-aarch64.a \
	${CLANG_RESOURCE_DIR}/lib/linux/libclang_rt.builtins-morello.a
