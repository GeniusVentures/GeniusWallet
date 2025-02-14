
cmake_minimum_required(VERSION 3.18)
set(CMAKE_VERBOSE_MAKEFILE on)

set(ARCH_BUILD_DIR /build/Android/)
set(ARCH_OUTPUT_DIR ${ARCH_BUILD_DIR}${CMAKE_BUILD_TYPE}/${ANDROID_ABI})

find_package(Vulkan REQUIRED)

include(../../cmake/CommonBuildParameters.cmake)
