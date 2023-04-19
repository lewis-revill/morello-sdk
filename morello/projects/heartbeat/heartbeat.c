/* SPDX-License-Identifier: BSD-3-Clause */

#define __STDC_LIMIT_MACROS

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>

#define SLEEP_INTERVAL		60

int main(int argc, char *argv[]) {
	uint64_t heartbeat = 0;

	while(1)
	{
		if (heartbeat == UINT64_MAX)
			heartbeat = 0;

		sleep(SLEEP_INTERVAL);

		heartbeat++;
#ifdef MORELLO_DEBUG
		printf("[MORELLO]: heartbeat: %lu\n", heartbeat);
#endif
	}

	return 0;
}
