// LD_PRELOAD shim: makes every dlopen of WebKitGTK fail as if the library were not installed.
#define _GNU_SOURCE
#include <dlfcn.h>
#include <string.h>
void *dlopen(const char *file, int mode) {
  static void *(*real)(const char *, int);
  if (!real) real = dlsym(RTLD_NEXT, "dlopen");
  if (file && strstr(file, "libwebkit2gtk")) return real("/nonexistent/libwebkit2gtk.so", mode);
  return real(file, mode);
}
