/* SPDX-License-Identifier: BSD-3-Clause */

#include <stdio.h>
#include <stdlib.h>

int main()
{
	char *buffer = malloc(10);

	printf("On Morello using an 11+ char string as input (e.g. \'AAAAAAAAAAA\') triggers a Bounds Checking Error.\n");

	printf("Input string: ");
	fflush(stdout);

	scanf("%s", buffer);
	printf("buffer: %s\n", buffer);

	free(buffer);

	return 0;
}

