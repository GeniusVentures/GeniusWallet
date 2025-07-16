
cmake_minimum_required(VERSION 3.18)
set(CMAKE_VERBOSE_MAKEFILE on)

set(BUILD_TYPE_SEARCH ${CMAKE_BUILD_TYPE})


# Fallback to Debug if still not set
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
  set(BUILD_TYPE_SEARCH "Debug")
endif()

set(ARCH_BUILD_DIR /build/Android/)
set(ARCH_OUTPUT_DIR ${ARCH_BUILD_DIR}${BUILD_TYPE_SEARCH}/${ANDROID_ABI})
set(ARCH_RELEASE_OUTPUT_DIR ${ARCH_BUILD_DIR}Release/${ANDROID_ABI})

#find_package(Vulkan REQUIRED)

include(../../cmake/CommonBuildParameters.cmake)
