/* SPDX-License-Identifier: BSD-3-Clause */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <sys/wait.h>

char *const env[] = {
	"PATH=/usr/sbin:/bin:/sbin",
	NULL,
};

const char *process[] = {
	"/sbin/heartbeat",
	NULL,
};

const char *shell = "/bin/sh";

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

int exec_cmd(const char *cmd)
{
	pid_t c_pid;

	c_pid = fork();

	if(c_pid == 0)
	{
		execle(cmd, cmd, NULL, env);

		printf("[MORELLO]: Cannot exec %s\n", cmd);
		exit(0);
	}

	return 0;
}

int exec_shell(const char *shell)
{
	pid_t c_pid;
	int c_status;

	c_pid = fork();

	if(c_pid == 0)
	{
		execle(shell, shell, NULL, env);

		printf("[MORELLO]: Cannot exec %s\n", shell);
		exit(0);
	} else {
		pid_t t_pid;

		do {
			t_pid = wait(&c_status);

			if (t_pid != c_pid)
				printf("[MORELLO]: Exit process: %d\n", t_pid);
		} while(t_pid != c_pid);

		return c_status;
	}
}

int main(int argc, char *argv[]) {
	int index = 0;
	int status = 0;

#ifndef MORELLO_DOCKER
	/* Mount filesystems */
	fs_mount("none", "/proc", "proc", 0, "");
	fs_mount("none", "/dev/pts", "devpts", 0, "");
	fs_mount("none", "/dev/mqueue", "mqueue", 0, "");
	fs_mount("none", "/dev/shm", "tmpfs", 0, "");
	fs_mount("none", "/sys", "sysfs", 0, "");
	fs_mount("none", "/sys/fs/cgroup", "cgroup", 0, "");
#endif

	/* Set hostname */
	sethostname("morello", sizeof("morello"));

	printf("Welcome to Morello PCuABI environment (busybox)!\n");
	printf("Have a lot of fun!\n\n");

#ifndef MORELLO_DOCKER
	/* Start Processes */
	while(process[index] != NULL)
	{
		printf("[MORELLO]: Starting %s...\n", process[index]);
		status = exec_cmd(process[index]);

		index++;
	}
#endif

	/* Start Shell */
	while(1)
	{
		printf("[MORELLO]: Starting %s...\n", shell);
		status = exec_shell(shell);

		sleep(1);
	}

	/* We should never reach this point */
	return status;
}
