# Project-level configuration.

cmake_minimum_required(VERSION 3.18)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "genius_wallet")

set(ABI_SUBFOLDER_NAME "/aarch64")
set(CMAKE_SYSTEM_NAME iOS)
#set(CMAKE_OSX_SYSROOT $(xcrun --sdk iphoneos --show-sdk-path))
set(CMAKE_OSX_DEPLOYMENT_TARGET 12.0)
set(CMAKE_OSX_ARCHITECTURES arm64)
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE YES)
set(CMAKE_Swift_COMPILER_FORCED true)

set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY ON)
set(CMAKE_USE_WIN32_THREADS_INIT OFF)
set(CMAKE_USE_PTHREADS_INIT ON)
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
# The unique GTK application identifier for this application. See:
# https://wiki.gnome.org/HowDoI/ChooseApplicationID

set(ARCH_BUILD_DIR /build/iOS/)
set(ARCH_OUTPUT_DIR ${ARCH_BUILD_DIR}${CMAKE_BUILD_TYPE})

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Load bundled libraries from the lib/ directory relative to the binary.
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Root filesystem for cross-building.
if(FLUTTER_TARGET_PLATFORM_SYSROOT)
  set(CMAKE_SYSROOT ${FLUTTER_TARGET_PLATFORM_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
endif()

# Define build configuration options.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE
    STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_14)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
  target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
endfunction()

#find_package(Vulkan REQUIRED)
set(THIRDPARTY_DIR "${CMAKE_BINARY_DIR}/../../../../thirdparty" CACHE PATH "Path to third-party dependencies")
set(SUPERGENIUS_SRC_DIR "${CMAKE_BINARY_DIR}/../../../../SuperGenius" CACHE PATH "Path to sgns dependencies")
set(GENIUSSDK_SRC_DIR "${CMAKE_BINARY_DIR}/../../../../GeniusSDK" CACHE PATH "Path to sdk dependencies")
# Flutter library and tool build rules.
#set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../flutter")
#add_subdirectory(${FLUTTER_MANAGED_DIR})
include(../../cmake/CommonBuildParameters.cmake)

