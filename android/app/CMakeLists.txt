
cmake_minimum_required(VERSION 3.18)
set(CMAKE_VERBOSE_MAKEFILE on)

set(CMAKE_BUILD_TYPE Release)
set(ARCH_OUTPUT_DIR /build/Android/${CMAKE_BUILD_TYPE}/${ANDROID_ABI})
set(ARCH_OUTPUT_DIR_REL /build/Android/Release/${ANDROID_ABI})

find_package(Vulkan REQUIRED)

include(../../cmake/CommonBuildParameters.cmake)
