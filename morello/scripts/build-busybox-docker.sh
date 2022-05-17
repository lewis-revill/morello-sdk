#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

MORELLO_BUILDROOT_FILES=${MORELLO_PROJECTS}/buildroot
MORELLO_MUSL_UTILS_FILES=${MORELLO_PROJECTS}/musl-utils
MORELLO_INIT_PROCESS=${MORELLO_PROJECTS}/init
MORELLO_EXAMPLES=${EXAMPLES_BIN}
MORELLO_ROOTFS_BIN=${MORELLO_ROOTFS}
MORELLO_ROOTFS_EXAMPLES=$MORELLO_ROOTFS_BIN/morello

MORELLO_BUILDROOT_URL="https://raw.githubusercontent.com/buildroot/buildroot/master"

declare -a BUILDROOT_FILES=( \
	"system/device_table.txt" \
	"system/skeleton/etc/group" \
	"system/skeleton/etc/passwd" \
	"system/skeleton/etc/shadow" \
)

MORELLO_MUSL_UTILS_URL="https://raw.githubusercontent.com/alpinelinux/aports/master/main/musl"

declare -a MUSL_UTILS_FILES=( \
	"getconf.c" \
	"getent.c" \
)

mkdir -p $MORELLO_BUILDROOT_FILES
mkdir -p $MORELLO_MUSL_UTILS_FILES

for file in "${BUILDROOT_FILES[@]}";
do
	TMP_DIR="$(dirname "$file")";
	mkdir -p "$MORELLO_BUILDROOT_FILES/$TMP_DIR";
	curl -fL -o "$MORELLO_BUILDROOT_FILES/$file" "$MORELLO_BUILDROOT_URL/$file";
done;

for file in "${MUSL_UTILS_FILES[@]}";
do
	curl -fL $MORELLO_MUSL_UTILS_URL/$file -o "$MORELLO_MUSL_UTILS_FILES/$file"
done

# Populate /etc filesystem
mkdir -p $MORELLO_ROOTFS_BIN/etc
cp -Rf $MORELLO_BUILDROOT_FILES/system/skeleton/etc $MORELLO_ROOTFS_BIN

# Create homes
cd $MORELLO_ROOTFS_BIN

# CVE-2019-5021, https://github.com/docker-library/official-images/pull/5880#issuecomment-490681907
grep -E '^root::' etc/shadow
sed -ri -e 's/^root::/root:*:/' etc/shadow
grep -E '^root:[*]:' etc/shadow

for homedir in $(awk -F ':' '{ print $3 ":" $4 "=" $6 }' etc/passwd);
do
	user="${homedir%%=*}";
	home="${homedir#*=}";
	home="./${home#/}";
	if [ ! -d "$home" ]; then
		mkdir -p "$home";
		chown "$user" "$home";
		chmod 755 "$home";
	fi;
done

# Set permissions
awk ' \
	!/^#/ { \
		if ($2 != "d" && $2 != "f") { \
			exit 1; \
		} \
		sub(/^\/?/, "./", $1); \
		if ($2 == "d") { \
			printf "mkdir -p %s\n", $1; \
		} \
		printf "chmod %s %s\n", $3, $1; \
	} \
' $MORELLO_BUILDROOT_FILES/system/device_table.txt | sh -eux

cd $MORELLO_PROJECTS

# Set correct timezone (UTC)
cp -Rf /usr/share/zoneinfo/UTC $MORELLO_ROOTFS_BIN/etc/localtime

# Generate musl utils makefile
cat > $MORELLO_MUSL_UTILS_FILES/Makefile << EOF
# SPDX-License-Identifier: BSD-3-Clause

CC=clang
ELF_PATCH=morello_elf
CMP=cmp -l
GAWK=gawk
MUSL_LIB=../../musl-bin/lib
CLANG_RESOURCE_DIR=\$(shell clang -print-resource-dir)

OUT=../../morello-rootfs/bin
# we want the same result no matter where we're cross compiling (x86_64, aarch64)
TARGET?=aarch64-linux-gnu

all:
	mkdir -p \$(OUT)
	\$(CC) -c -g -nostdinc -isystem ../../musl-bin/include \
		-march=morello+c64 -mabi=purecap getconf.c -o \$(OUT)/getconf.c.o \
		--target=\$(TARGET)
	\$(CC) -c -g -nostdinc -isystem ../../musl-bin/include \
		-march=morello+c64 -mabi=purecap getent.c -o \$(OUT)/getent.c.o \
		--target=\$(TARGET)
	\$(CC) --target=\$(TARGET) -fuse-ld=lld -march=morello+c64 -mabi=purecap \
		\$(MUSL_LIB)/crt1.o \
		\$(MUSL_LIB)/crti.o \
		\$(CLANG_RESOURCE_DIR)/lib/linux/clang_rt.crtbegin-morello.o \
		\$(OUT)/getconf.c.o \
		\$(CLANG_RESOURCE_DIR)/lib/linux/libclang_rt.builtins-morello.a \
		\$(CLANG_RESOURCE_DIR)/lib/linux/clang_rt.crtend-morello.o \
		\$(MUSL_LIB)/crtn.o \
		-nostdlib -L\$(MUSL_LIB) -lc -o \$(OUT)/getconf -static
	\$(CC) --target=\$(TARGET) -fuse-ld=lld -march=morello+c64 -mabi=purecap \
		\$(MUSL_LIB)/crt1.o \
		\$(MUSL_LIB)/crti.o \
		\$(CLANG_RESOURCE_DIR)/lib/linux/clang_rt.crtbegin-morello.o \
		\$(OUT)/getent.c.o \
		\$(CLANG_RESOURCE_DIR)/lib/linux/libclang_rt.builtins-morello.a \
		\$(CLANG_RESOURCE_DIR)/lib/linux/clang_rt.crtend-morello.o \
		\$(MUSL_LIB)/crtn.o \
		-nostdlib -L\$(MUSL_LIB) -lc -o \$(OUT)/getent -static
	\$(ELF_PATCH) \$(OUT)/getconf
	\$(ELF_PATCH) \$(OUT)/getent
	rm \$(OUT)/getconf.c.o
	rm \$(OUT)/getent.c.o

clean:
	rm \$(OUT)/morello-helloworld
EOF

# Build musl utils
cd $MORELLO_MUSL_UTILS_FILES
make
cd $MORELLO_PROJECTS

# Build init process
if [ "$MODE" = "aarch64" -a $(uname -m) = "aarch64" ]; then
	cd $MORELLO_INIT_PROCESS
	make
	cp bin/init $MORELLO_ROOTFS_BIN/sbin/init.aarch64
	cd $MORELLO_PROJECTS
fi

# Copy morello examples
mkdir -p $MORELLO_ROOTFS_EXAMPLES
cp -Rf $MORELLO_EXAMPLES/* $MORELLO_ROOTFS_EXAMPLES

# Create Docker File
mkdir -p $MORELLO_DOCKER
cat > $MORELLO_DOCKER/Dockerfile << EOF
FROM scratch
ADD morello-busybox-docker.tar.xz /
CMD ["/sbin/init.aarch64"]
EOF

# Create Docker Image
cd $MORELLO_ROOTFS_BIN
tar -cJvf $MORELLO_DOCKER/morello-busybox-docker.tar.xz .
