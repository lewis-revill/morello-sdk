# Morello bootstrap scripts

## Pre-requisites
A **Debian based aarch64** environment with **network access** and this repository available inside.  
Make sure you have around 4GB of available disk space for the whole process.

## Setting up the build environment
`# apt install git build-essential`

## Building
### Quick build:
```
cd morello-aarch64/morello
source ./env/morello-aarch64
./scripts/build-all.sh
```

On success, your binary is `morello-aarch64/morello/bin/main`.

### Step by step build explanation
In `morello-aarch64/morello`:

1. `env/morello-aarch64`: set up $PATH for the Morello toolchain  
Sourcing this sets up $PATH such that the Morello supporting LLVM overshadows the system one (since not upstreamed yet).  
**Required for steps 4 to 6**  

1. `scripts/build-all.sh`: Runs all steps in sequence  
Download and compile everything. Requires step 1.  

1. `scripts/download-llvm-musl.sh`: Download required tools  
This clones a binary release of LLVM to `llvm`, its sources to `llvm-project` and the musl sources to `musl`.  
**NOTE**: this **downloads about 3GB** of stuff. This can be done on another machine and copied over for speed.  

1. `scripts/build-musl.sh`: Build Musl  
This builds llvm's compiler-rt into `llvm` and then runs `./configure && make` in musl's root directory **with libshim enabled**.  
Downloads a few MB of dependencies. Takes a while.  

1. `tools/Makefile`: Compile `morello_elf`  
This utility sets up the ELF headers of the Morello binary. Necessary since the ELF format is not finalized yet.  

1. `test-app/Makefile`: Compile a hello world program  
Compiles a simple hello world for the Morello architecture and passes it to morello\_elf.  
Output is in `bin`.  

A note on the long linker command: A good general purpose guide to replacing the libc is yet to be found. To help you understand what the command does you should:

* refer to `man gcc` and look up each argument  
* refer to the [gcc docs](https://gcc.gnu.org/onlinedocs/gcc/) and read through the chapters on Standards and Standard Libraries  
* refer to [this gentoo doc](https://dev.gentoo.org/~vapier/crt.txt) for an explanation of what all the crt files do  
* refer to musl's source code for what the other `crt`s do  
(crt = C RunTime)  

### Note on samba
Building this on a samba share is possible, but wonky. The llvm builds use **symlinks** which need extra care.

