#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause

MORELLO_BUILDROOT_FILES=${MORELLO_PROJECTS}/buildroot
MORELLO_MUSL_UTILS_FILES=${MORELLO_PROJECTS}/musl-utils
MORELLO_INIT_PROCESS=${MORELLO_PROJECTS}/init
MORELLO_HEARTBEAT_PROCESS=${MORELLO_PROJECTS}/heartbeat
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

# Create proc an sys
mkdir -p ./proc
chmod 755 ./proc
mkdir -p ./sys
chmod 755 ./sys

# Create /init
cat > ./init << EOF
#!/bin/busybox sh

# SPDX-License-Identifier: BSD-3-Clause

mount() {
	/bin/busybox mount "\$@"
}

grep() {
	/bin/busybox grep "\$@"
}

mount -t proc proc /proc
grep -qE \$'\\t'"devtmpfs\$" /proc/filesystems && mount -t devtmpfs dev /dev
mount -t sysfs sysfs /sys

! grep -qE $'\\t'"devtmpfs\$" /proc/filesystems && mdev -s

for script in /etc/init.d/*.sh ;
do
	test -e "\$script" && . "\$script"
done

printf "Welcome to Morello PCuABI environment (busybox)!\n"
printf "Have a lot of fun!\n\n"

exec /sbin/init.morello
exec setsid cttyhack sh
printf "setsid failed fallback to /bin/sh\n"
exec /bin/sh
EOF

chmod 755 ./init

# Create example startup script
mkdir -p ./etc/init.d

cat > ./etc/init.d/0-startup.sh << EOF
#!/bin/busybox sh

# SPDX-License-Identifier: BSD-3-Clause

printf "Startup...\n"
EOF

chmod 755 ./etc/init.d/0-startup.sh

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
MUSL_HOME=../../musl-bin
CLANG_RESOURCE_DIR=\$(shell clang -print-resource-dir)

OUT=../../morello-rootfs/bin
# we want the same result no matter where we're cross compiling (x86_64, aarch64)
TARGET?=aarch64-linux-musl_purecap

all:
	mkdir -p \$(OUT)
	\$(CC) -c -g -march=morello+c64 \
		--target=\$(TARGET) --sysroot \$(MUSL_HOME) \
		getconf.c -o \$(OUT)/getconf.c.o
	\$(CC) -c -g -march=morello+c64 \
		--target=\$(TARGET) --sysroot \$(MUSL_HOME) \
		getent.c -o \$(OUT)/getent.c.o
	\$(CC) -fuse-ld=lld -march=morello+c64 \
		--target=\$(TARGET) --sysroot \$(MUSL_HOME) \
		-rtlib=compiler-rt \
		\$(OUT)/getconf.c.o -o \$(OUT)/getconf -static
	\$(CC) -fuse-ld=lld -march=morello+c64 \
		--target=\$(TARGET) --sysroot \$(MUSL_HOME) \
		-rtlib=compiler-rt \
		\$(OUT)/getent.c.o -o \$(OUT)/getent -static
	\$(ELF_PATCH) \$(OUT)/getconf
	\$(ELF_PATCH) \$(OUT)/getent
	rm \$(OUT)/getconf.c.o
	rm \$(OUT)/getent.c.o

clean:
	rm \$(OUT)/getconf
	rm \$(OUT)/getent
EOF

# Build musl utils
cd $MORELLO_MUSL_UTILS_FILES
make
cd $MORELLO_PROJECTS

# Build init process
if [ "$OPTIONS_MODE" = "aarch64" -a $(uname -m) = "aarch64" ]; then
	cd $MORELLO_INIT_PROCESS
	make
	cp bin/init $MORELLO_ROOTFS_BIN/sbin/init.morello
	cp bin/init.docker $MORELLO_ROOTFS_BIN/sbin/init.morello.docker
	cp bin/init.aarch64 $MORELLO_ROOTFS_BIN/sbin/init.aarch64
	cp bin/init.aarch64.docker $MORELLO_ROOTFS_BIN/sbin/init.aarch64.docker

	cd $MORELLO_HEARTBEAT_PROCESS
	make
	cp bin/heartbeat $MORELLO_ROOTFS_BIN/sbin/heartbeat

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
