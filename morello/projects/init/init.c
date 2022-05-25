/* SPDX-License-Identifier: BSD-3-Clause */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <sys/stat.h>

char *const env[] = {
	"PATH=/usr/sbin:/bin:/sbin",
	NULL,
};

void fs_mount(const char *src, const char *dst,
	      const char *fs_type, unsigned long mount_flags,
	      const void *data)
{
	struct stat info;

	if (stat(dst, &info) == -1 && errno == ENOENT) {
		printf("Creating %s\n", dst);
		if (mkdir(dst, 0755) < 0) {
			perror("Creating directory failed");
			exit(1);
		}
	}

	printf("Mounting %s...\n", dst);

	if (mount(src, dst, fs_type, mount_flags, data) < 0) {
		printf("[ERROR]: cannot mount %s\n", dst);
		exit(1);
	}
}

int main(int argc, char *argv[]) {
#ifndef MORELLO_DOCKER
	fs_mount("none", "/proc", "proc", 0, "");
	fs_mount("none", "/dev/pts", "devpts", 0, "");
	fs_mount("none", "/dev/mqueue", "mqueue", 0, "");
	fs_mount("none", "/dev/shm", "tmpfs", 0, "");
	fs_mount("none", "/sys", "sysfs", 0, "");
	fs_mount("none", "/sys/fs/cgroup", "cgroup", 0, "");
#endif

	sethostname("morello", sizeof("morello"));

	execle("/bin/sh", "/bin/sh", NULL, env);
	perror("Cannot exec /bin/sh");
	return 1;
}
