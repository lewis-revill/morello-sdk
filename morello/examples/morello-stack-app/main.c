/* SPDX-License-Identifier: BSD-3-Clause */

#include <stdio.h>
#include <stdlib.h>

void stack_test(char c, int size)
{
	volatile char s_array[128];

	for(int i = 0; i < size; i++)
		s_array[i] = c;
}

/* Note: this application is compiled with -fno-stack-protector */

int main()
{
	printf("Test 1: Write inside the array:");
	stack_test('A', 64);
	printf(" OK\n");

	printf("Test 2: Write beyond the array (expected SEGFAULT):");
	fflush(stdout);
	stack_test('A', 131);
	printf(" OK\n");

	return 0;
}

