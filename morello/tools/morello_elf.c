/* SPDX-License-Identifier: BSD-3-Clause */

#include <string.h>
#include <sys/mman.h>
#include <elf.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <assert.h>

#define EF_AARCH64_CHERI_PURECAP	0x00010000

#define LOG(x)		printf("[Morello_ELF]: %s", x)
#define ASSERT(x)	assert(x)

int main(int argc, char *argv[]) {
	const char *bin = NULL;
	int fd = -1;
	struct stat stat = {0};
	Elf64_Ehdr eh;

	if (argc < 2) {
		LOG("usage: morello_elf <binary>\n");
		goto out;
	}

	fd = open(argv[1], O_RDWR);
	if (fd < 0) {
		perror("open");
		goto out;
	}

	if (fstat(fd, &stat) != 0) {
		perror("stat");
		goto out;
	}

	bin = mmap(NULL, stat.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (bin == MAP_FAILED) {
		perror("mmap");
		goto out;
	}

	LOG("Binary loaded correctly!\n");

	if ((unsigned char)bin[EI_MAG0] == 0x7f &&
	    (unsigned char)bin[EI_MAG1] == 'E' &&
            (unsigned char)bin[EI_MAG2] == 'L' &&
            (unsigned char)bin[EI_MAG3] == 'F') {
		LOG("ELF detected\n");
	} else {
		LOG("Unsupported Format\n");
		goto out;
	}

	if ((unsigned char)bin[EI_CLASS] == ELFCLASS64) {
    		LOG("ELF64 detected\n");
	} else {
		LOG("Unsupported Format\n");
		goto out;
	}

	ASSERT(lseek(fd, (off_t)0, SEEK_SET) == (off_t)0);
	ASSERT(read(fd, (void *)&eh, sizeof(Elf64_Ehdr)) == sizeof(Elf64_Ehdr));
	LOG("ELF64 header found\n");

	if (eh.e_machine == EM_AARCH64) {
		LOG("EM_AARCH64 binary detected\n");

		if (eh.e_flags != EF_AARCH64_CHERI_PURECAP) {
			eh.e_flags = EF_AARCH64_CHERI_PURECAP;

			ASSERT(lseek(fd, (off_t)0, SEEK_SET) == (off_t)0);
			if (write(fd, (void *)&eh, sizeof(Elf64_Ehdr)) ==
				sizeof(Elf64_Ehdr))
				LOG("e_flags updated with EF_AARCH64_CHERI_PURECAP\n");
			else
				LOG("Something went wrong in updating e_flags\n");
		} else {
				LOG("EF_AARCH64_CHERI_PURECAP binary detected\n");
		}
	} else {
		LOG("Unsupported Format\n");
		goto out;
	}

out:
	if (fd != -1) {
		close(fd);
	}
	if (bin != MAP_FAILED) {
		munmap((void *)bin, stat.st_size);
	}

	return 0;
}
