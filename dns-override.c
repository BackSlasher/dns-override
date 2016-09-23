#define _GNU_SOURCE

#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <stdlib.h>

const char *RESOLV_CONF = "/etc/resolv.conf";
const int RESOLV_SIZE = 16;

const char *RESOLV_ENV = "RESOLV_CONF";

FILE *(*original_fopen)(const char*, const char*) = NULL; 
FILE *(*original_fopen64)(const char*, const char*) = NULL;

void init_fopen_override() {
  if (original_fopen == NULL)
    original_fopen = dlsym(RTLD_NEXT, "fopen");
  if (original_fopen64 == NULL)
    original_fopen64 = dlsym(RTLD_NEXT, "fopen64");
}

char *better_resolv = NULL;
int better_resolv_inited=0;

// No fmemopen64 so implementing the same for both functions
FILE *init_better_resolv() {
  // Singleton
  if (!better_resolv_inited) {
    better_resolv_inited=1;
    better_resolv = getenv(RESOLV_ENV);
    // Print warning message
    if (!better_resolv)
      fprintf(STD_ERR, "dns-override: No env var %s, will return unmodified file\n", RESOLV_ENV);
  }
  if (better_resolv)
    return fmemopen(better_resolv, strlen(better_resolv), "r");
  else
    return NULL;
}

FILE *fopen(const char *path, const char *mode) {
    init_fopen_override();
    // If it's our file
    if(!strncmp(RESOLV_CONF, path, RESOLV_SIZE)) {
      FILE *res = init_better_resolv();
      // Try returning our file
      if (res) return res;
    }
    return (*original_fopen)(path, mode);
}

FILE *fopen64(const char *path, const char *mode) {
    init_fopen_override();
    if(!strncmp(RESOLV_CONF, path, RESOLV_SIZE)) {
      FILE *res = init_better_resolv();
      if (res) return res;
    }
    return (*original_fopen64)(path, mode);
}
