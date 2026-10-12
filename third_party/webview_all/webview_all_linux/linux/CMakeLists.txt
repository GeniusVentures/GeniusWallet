cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "webview_all_linux")
project(${PROJECT_NAME} LANGUAGES CXX)

cmake_policy(VERSION 3.10...3.24)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

find_package(PkgConfig REQUIRED)
# Headers only. WebKitGTK is dlopen()ed at runtime (4.1, else 4.0) so the app
# starts without it; the libsoup 2 code paths need the 4.0 headers to build.
pkg_check_modules(WEBKIT webkit2gtk-4.0)
if(NOT WEBKIT_FOUND)
  message(FATAL_ERROR
    "webkit2gtk-4.0 development headers not found. They are needed to build, "
    "not to run. Hosts that ship only 4.1 (Ubuntu 24.04+) can build in the "
    "AlmaLinux 8 CI image (ghcr.io/geniusventures/almalinux-8, plus "
    "webkit2gtk3-devel); see README 'Build on Linux'.")
endif()

add_library(${PLUGIN_NAME} SHARED
  "src/common/method_channel_utils.cc"
  "src/platform/flutter_view.cc"
  "src/plugin/webview_all_linux_plugin.cc"
  "src/plugin/root_channel.cc"
  "src/webview/linux_webview.cc"
  "src/webview/download_policy.cc"
  "src/webview/webview_javascript.cc"
  "src/webview/webview_method_handler.cc"
  "src/webview/webkit_runtime.cc"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden
)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_include_directories(${PLUGIN_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/src"
  ${WEBKIT_INCLUDE_DIRS}
)
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK ${CMAKE_DL_LIBS})
# A WebKit call that bypasses the dlsym table fails the build, not the launch.
target_link_options(${PLUGIN_NAME} PRIVATE "-Wl,--no-undefined")
