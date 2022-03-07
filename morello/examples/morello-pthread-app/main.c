/* SPDX-License-Identifier: BSD-3-Clause */

#include <pthread.h>
#include <stdio.h>
#include <string.h>

#define MAGIC 0xb0bacafeUL

static void *routine(void *args);

int main() {
    int ret;

    pthread_attr_t attr;
    printf("INFO: pthread_attr_init(%p)...\n", (void *) &attr);
    ret = pthread_attr_init(&attr);
    if (ret) {
        printf("ERROR: pthread_attr_init() failed with return code %d\n", ret);
        return 1;
    }

    pthread_t thread;
    char *arg_str = "hello world from args!";
    printf("INFO: pthread_create(%p, %p, %p, %p)...\n", (void *) &thread, (void *) &attr, (void *) routine, (void *) arg_str);
    ret = pthread_create(&thread, &attr, routine, arg_str);
    if (ret) {
        printf("ERROR: pthread_create() failed with return code %d\n", ret);
        return 1;
    }

    void *thread_ret;
    printf("INFO: pthread_join(%p, %p)...\n", (void *) thread, (void *) &thread_ret);
    ret = pthread_join(thread, &thread_ret);
    if (ret) {
        printf("ERROR: pthread_join() failed with return code %d\n", ret);
        return 1;
    }

    if (thread_ret != (void *) MAGIC) {
        printf("ERROR: thread returned with wrong value %p != %p\n", thread_ret, (void *) MAGIC);
        return 1;
    }

    printf("INFO: main thread returning 0\n");
    return 0;
}

static void *routine(void *args) {
    char *str = (char *) args;
    printf("[thread] INFO: args string is: %s\n", str);

    if (strcmp(str, "hello world from args!")) {
        printf("[thread] ERROR: unexpected args, returning %p\n", (void *) NULL);
        return (void *) NULL;
    }

    printf("[thread] INFO: returning %p\n", (void *) MAGIC);
    return (void *) MAGIC;
}

