#!/usr/bin/env bash

MODE="${MODE:-native}"
BRANCH=

if [ "$MODE" = "native" ]; then
    BRANCH="morello/linux-aarch64-release-1.1"
elif [ "$MODE" = "cross" ]; then
    BRANCH="morello/baremetal-release-1.1"
fi

# Clone Clang
git clone https://git.morello-project.org/morello/llvm-project-releases llvm
(cd llvm; git checkout $BRANCH)

# Clone Clang sources to build compiler-rt for Morello
git clone https://git.morello-project.org/morello/llvm-project.git -b morello/release-1.1 --depth 1

# Clone Musl
git clone https://git.morello-project.org/morello/musl-libc.git -b morello/master musl
