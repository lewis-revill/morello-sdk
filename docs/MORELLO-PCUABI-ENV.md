# Morello bootstrap scripts

## Pre-requisites
A **Debian 11 based aarch64 or x86_64** environment with **network access** and this repository available inside.  
Make sure you have around 4GB of available disk space for the whole process.

The scripts have not been tested in other environments, although any aarch64 based Linux might work.

**Requirements:** GIT 1.8.2 (for submodule branch support).

## Setting up the build environment
`$ apt install git build-essential python3`

If cross compiling on x86 you also need:  
`$ apt install libtinfo5 linux-libc-dev-arm64-cross`

## Building
### Quick build:
```
$ cd morello-sdk/morello
$ source ./env/morello-sdk
$ ./scripts/build-all.sh [options]
```
Which will perform a full cross build on aarch64 host. You can optionally pass `--x86_64` to `build-all.sh` to do a cross-build from an x86_64 host.

```
$ ./scripts/build-all.sh --help

Usage: ./scripts/build-all.sh [options]

OPTIONS:
[ARCH]:
  --aarch64           build on an aarch64 host [DEFAULT]
  --x86_64            build on an x86_64 host

[MODULES]:
  --firmware          generate the firmware for Morello
  --linux             builds linux for Morello
  --kselftest         builds kselftest for Morello
  --c-apps            builds example c applications for Morello
  --rootfs            builds a busybox based rootfs for Morello

  --clean             cleans all the selected projects

  --help              this help message
```

On success, your binary is `morello-sdk/morello/examples/bin/main`.

Note: To reset the environment to the default configuration execute:
```
$ source ./env/morello-sdk-restore
```

### Step by step build explanation
In `morello-sdk/morello`:

1. `env/morello-sdk`: set up $PATH for the Morello toolchain  
Sourcing this sets up $PATH such that the Morello supporting LLVM overshadows the system one (since not upstreamed yet).  
**Required for steps 4 to 6**  

1. `scripts/build-all.sh`: Runs all steps in sequence  
Download and compile everything.
Accepts either `--x86_64` or `--aarch64`. The default is `--aarch64` and is assumed if neither is specified.  
The `--aarch64` switch downloads and builds everything from an aarch64 host.  
Passing `--x86_64` assumes an x86\_64 host  

1. `scripts/download-llvm-musl.sh`: Download required tools  
This clones a binary release of LLVM to `llvm`, its sources to `llvm-project` and the musl sources to `musl`.  
Accepts a variable MODE={aarch64, x86_64} and will checkout aarch64 or x86\_64 binaries respectively.  
**NOTE**: this process **downloads about 3GB**. When building on an emulator (e.g. qemu) this can be done on the host machine and copied over.  

1. `scripts/build-musl.sh`: Build Musl  
This runs `./configure && make` in musl's root directory **with libshim enabled**.  
Downloads a few MB of dependencies. Takes a while.  

1. `scripts/build-libraries.sh`: Build Compiler-RT  
This script builds llvm's compiler-rt and the crt*.o objects.  

1. `tools/Makefile`: Compile `morello_elf`  
This utility sets up the ELF headers of the Morello binary. Necessary since the ELF format is not finalized yet.  

1. `examples/test-app/Makefile`: Compile a hello world program  
Compiles a simple hello world for the Morello architecture and passes it to morello\_elf.  
Output is in `examples/bin`.  

1. `examples/morello-heap-app/Makefile`: Compile a capability based heap test program  
Compiles a simple capability based heap test for the Morello architecture and passes it to morello\_elf.  
Output is in `examples/bin`.  

1. `examples/morello-stack-app/Makefile`: Compile a capability based stack test program  
Compiles a simple capability based stack test for the Morello architecture and passes it to morello\_elf.  
**NOTE** : To see the differences in behavior in between aarch64 and Morello, it is possible to recompile the same program for aarch64 and compare the results with what happens on Morello. This should point out that just recompiling the same code on Morello makes it more robust and secure.  
Output for Morello is in `examples/bin`.  

**NOTE**: Please refer to the following links to have a clear understanding of the implemented process:

* refer to `man gcc` and look up each argument  
* refer to the [gcc docs](https://gcc.gnu.org/onlinedocs/gcc/) and read through the chapters on Standards and Standard Libraries  
* refer to [this gentoo doc](https://dev.gentoo.org/~vapier/crt.txt) for an explanation of what all the crt files do  
* refer to musl's source code for what the other `crt`s do  
(crt = C RunTime)  

### Note on samba
Building this on a samba share is possible, but it takes longer. The llvm builds use **symlinks** which need extra care.

