#!/usr/bin/env bash

source ./env/morello-aarch64-versions

MODE="${MODE:-native}"
BRANCH=

if [ "$MODE" = "native" ]; then
    BRANCH="morello/linux-aarch64-release-$MORELLO_COMPILER_VERSION"
elif [ "$MODE" = "cross" ]; then
    BRANCH="morello/baremetal-release-$MORELLO_COMPILER_VERSION"
fi

# Clone Clang
git clone https://git.morello-project.org/morello/llvm-project-releases llvm
(cd llvm; git checkout $BRANCH)

# Clone Clang sources to build compiler-rt for Morello
git clone https://git.morello-project.org/morello/llvm-project.git -b morello/release-$MORELLO_COMPILER_VERSION --depth 1

# Clone Musl
git clone https://git.morello-project.org/morello/musl-libc.git -b morello/master musl
