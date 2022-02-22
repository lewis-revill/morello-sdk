/* SPDX-License-Identifier: BSD-3-Clause */

#include <sys/auxv.h>
#include <errno.h>
#include <stdio.h>

int main()
{
    void *entry = getauxptr(AT_ENTRY);
    unsigned long perms = __builtin_cheri_perms_get(entry);

    if (!entry) {
        printf("ERROR: getauxptr(AT_ENTRY) failed\n");
        return 1;
    }
    printf("getauxptr(AT_ENTRY) returned a capability with value %p\n", entry);
    if (!__builtin_cheri_tag_get(entry)) {
        printf("ERROR: getauxptr(AT_ENTRY) didn't return a tagged capability\n");
        return 1;
    }
    if (!(perms & __CHERI_CAP_PERMISSION_PERMIT_LOAD__)) {
        printf("ERROR: getauxptr(AT_ENTRY) didn't return a capability with valid permissions\n");
        return 1;
    }

    long hwcap = getauxval(AT_HWCAP);
    if (!hwcap) {
        printf("ERROR: getauxval(AT_HWCAP) failed\n");
        return 1;
    }
    printf("getauxval(AT_HWCAP) returned an integer with value 0x%lx\n", hwcap);

    void *x = getauxptr(AT_HWCAP);
    if (x || errno != ENOENT) {
        printf("ERROR: getauxptr(AT_HWCAP) should have failed as AT_HWCAP is not a pointer\n");
        return 1;
    }

    long y = getauxval(AT_RANDOM);
    if (y || errno != ENOENT) {
        printf("ERROR: getauxval(AT_RANDOM) should have failed as AT_RANDOM is a pointer\n");
        return 1;
    }

    return 0;
}

