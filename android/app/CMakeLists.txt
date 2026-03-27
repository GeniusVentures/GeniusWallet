
cmake_minimum_required(VERSION 3.18)
set(CMAKE_VERBOSE_MAKEFILE on)

set(BUILD_TYPE_SEARCH ${CMAKE_BUILD_TYPE})


# Fallback to Debug if still not set
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
  set(BUILD_TYPE_SEARCH "Debug")
endif()

# AGP/Flutter may pass lowercase or non-Release variants (e.g. release, relwithdebinfo).
# Our thirdparty artifacts are published under /build/Android/Release/<abi>.
if(CMAKE_BUILD_TYPE)
  string(TOUPPER "${CMAKE_BUILD_TYPE}" _CMAKE_BUILD_TYPE_UPPER)
  if(_CMAKE_BUILD_TYPE_UPPER STREQUAL "RELEASE" OR
     _CMAKE_BUILD_TYPE_UPPER STREQUAL "RELWITHDEBINFO" OR
     _CMAKE_BUILD_TYPE_UPPER STREQUAL "MINSIZEREL")
    set(BUILD_TYPE_SEARCH "Release")
  elseif(_CMAKE_BUILD_TYPE_UPPER STREQUAL "DEBUG")
    set(BUILD_TYPE_SEARCH "Debug")
  endif()
endif()

set(ARCH_BUILD_DIR /build/Android/)
set(ARCH_OUTPUT_DIR ${ARCH_BUILD_DIR}${BUILD_TYPE_SEARCH}/${ANDROID_ABI})
set(ARCH_RELEASE_OUTPUT_DIR ${ARCH_BUILD_DIR}Release/${ANDROID_ABI})

message(STATUS "Android build type normalize: CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}, BUILD_TYPE_SEARCH=${BUILD_TYPE_SEARCH}, ABI=${ANDROID_ABI}")

#find_package(Vulkan REQUIRED)

include(../../cmake/CommonBuildParameters.cmake)
