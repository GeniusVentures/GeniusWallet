/**
 * @file webkit_runtime.cc
 * @brief Loads WebKitGTK 4.1 or 4.0 with dlopen() and resolves its symbols.
 */
#define GW_WEBKIT_NO_REDIRECT
#include "webview/webkit_runtime.h"

#include <dlfcn.h>

#include <cstdio>
#include <cstring>

GwWebKitApi gw_webkit = {};

template <typename T>
static void resolve(void *handle, const char *name, T &slot,
                    const char **missing) {
  slot = reinterpret_cast<T>(dlsym(handle, name));
  if (slot == nullptr && missing != nullptr && *missing == nullptr) {
    *missing = name;
  }
}

// libsoup 2 and 3 abort the process when mapped into the same one, so a
// WebKit built for the other major must not be loaded.
static bool soup_mapped(const char *name) {
  FILE *maps = fopen("/proc/self/maps", "r");
  if (maps == nullptr) {
    return false;
  }
  char line[4096];
  bool found = false;
  while (!found && fgets(line, sizeof(line), maps) != nullptr) {
    found = strstr(line, name) != nullptr;
  }
  fclose(maps);
  return found;
}

static gboolean load() {
  // 4.1 first: on distros that ship both, 4.0 is the legacy package. Only one
  // may load. The soname list is fixed, so no environment or path decides what
  // gets loaded.
  struct Candidate {
    const char *library;
    const char *conflicting_soup;
  };
  static const Candidate kLibraries[] = {
      {"libwebkit2gtk-4.1.so.0", "libsoup-2.4"},
      {"libwebkit2gtk-4.0.so.37", "libsoup-3.0"}};
  void *handle = nullptr;
  const char *library = nullptr;
  for (const Candidate &candidate : kLibraries) {
    if (soup_mapped(candidate.conflicting_soup)) {
      g_message("webview_all_linux: skipping %s, %s is already loaded",
                candidate.library, candidate.conflicting_soup);
      continue;
    }
    handle = dlopen(candidate.library, RTLD_NOW | RTLD_LOCAL);
    if (handle != nullptr) {
      library = candidate.library;
      break;
    }
    g_message("webview_all_linux: cannot load %s: %s", candidate.library,
              dlerror());
  }
  if (handle == nullptr) {
    g_warning("webview_all_linux: WebKitGTK unavailable");
    return FALSE;
  }

  const char *missing = nullptr;
#define GW_RESOLVE_REQUIRED(name) resolve(handle, #name, gw_webkit.name, &missing);
  GW_WEBKIT_REQUIRED(GW_RESOLVE_REQUIRED)
#undef GW_RESOLVE_REQUIRED

  resolve(handle, "soup_message_get_status", gw_webkit.soup3_message_get_status,
          nullptr);
  if (gw_webkit.soup3_message_get_status != nullptr) {
    resolve(handle, "soup_message_get_method",
            gw_webkit.soup3_message_get_method, &missing);
    resolve(handle, "soup_message_get_request_headers",
            gw_webkit.soup3_message_get_request_headers, &missing);
    resolve(handle, "soup_message_get_response_headers",
            gw_webkit.soup3_message_get_response_headers, &missing);
    resolve(handle, "soup_message_set_request_body_from_bytes",
            gw_webkit.soup3_message_set_request_body_from_bytes, &missing);
    resolve(handle, "soup_session_send_and_read_async",
            gw_webkit.soup3_session_send_and_read_async, &missing);
    resolve(handle, "soup_session_send_and_read_finish",
            gw_webkit.soup3_session_send_and_read_finish, &missing);
    resolve(handle, "g_uri_parse", gw_webkit.g_uri_parse, &missing);
    resolve(handle, "g_uri_get_host", gw_webkit.g_uri_get_host, &missing);
    resolve(handle, "g_uri_unref", gw_webkit.g_uri_unref, &missing);
  } else {
#define GW_RESOLVE_SOUP2(name) resolve(handle, #name, gw_webkit.name, &missing);
    GW_WEBKIT_SOUP2(GW_RESOLVE_SOUP2)
#undef GW_RESOLVE_SOUP2
  }

  resolve(handle, "webkit_web_view_evaluate_javascript",
          gw_webkit.evaluate_javascript, nullptr);
  resolve(handle, "webkit_web_view_evaluate_javascript_finish",
          gw_webkit.evaluate_javascript_finish, nullptr);
  if (gw_webkit.evaluate_javascript == nullptr ||
      gw_webkit.evaluate_javascript_finish == nullptr) {
    gw_webkit.evaluate_javascript = nullptr;
    gw_webkit.evaluate_javascript_finish = nullptr;
    resolve(handle, "webkit_web_view_run_javascript", gw_webkit.run_javascript,
            &missing);
    resolve(handle, "webkit_web_view_run_javascript_finish",
            gw_webkit.run_javascript_finish, &missing);
    resolve(handle, "webkit_javascript_result_unref",
            gw_webkit.javascript_result_unref, &missing);
  }

  // Never dlclose: WebKit registers GTypes and threads that outlive us.
  if (missing != nullptr) {
    g_warning("webview_all_linux: %s lacks %s", library, missing);
    return FALSE;
  }
  g_message("webview_all_linux: loaded %s (WebKitGTK %u.%u.%u, %s, %s)",
            library, gw_webkit.webkit_get_major_version(),
            gw_webkit.webkit_get_minor_version(),
            gw_webkit.webkit_get_micro_version(),
            gw_webkit.soup3_message_get_status != nullptr ? "libsoup3"
                                                          : "libsoup2",
            gw_webkit.evaluate_javascript != nullptr ? "evaluate_javascript"
                                                     : "run_javascript");
  return TRUE;
}

gboolean webkit_runtime_load() {
  static const gboolean loaded = load();
  return loaded;
}
