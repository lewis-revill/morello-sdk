#!/usr/bin/env bash

# Clone Clang
git clone https://git.morello-project.org/morello/llvm-project-releases -b morello/linux-aarch64-release-1.1 llvm

# Clone Clang sources to build compiler-rt for Morello
git clone https://git.morello-project.org/morello/llvm-project.git -b morello/release-1.1 --depth 1

# Clone Musl
git clone https://git.morello-project.org/morello/musl-libc.git -b morello/master musl
