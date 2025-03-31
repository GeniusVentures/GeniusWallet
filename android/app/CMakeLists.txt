
cmake_minimum_required(VERSION 3.18)
set(CMAKE_VERBOSE_MAKEFILE on)

set(BUILD_TYPE_SEARCH ${CMAKE_BUILD_TYPE})
# Read CMAKE_BUILD_TYPE from environment if passed via CMAKE_ARGUMENTS
if(DEFINED ENV{CMAKE_ARGUMENTS})
    string(REGEX MATCH "-DCMAKE_BUILD_TYPE=([^ ]+)" _match "$ENV{CMAKE_ARGUMENTS}")
    if(_match)
        if(${CMAKE_MATCH_1} STREQUAL "RelWithDebInfo")
          set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "Profile flags" FORCE)
          set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "Profile flags" FORCE)
          set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "Release flags" FORCE)
          set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "Release flags" FORCE)
          set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "Debug flags" FORCE)
          set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "Debug flags" FORCE)
          set(BUILD_TYPE_SEARCH "RelWithDebInfo")
        else()
          set(CMAKE_BUILD_TYPE "${CMAKE_MATCH_1}" CACHE STRING "Flutter build mode" FORCE)
          set(BUILD_TYPE_SEARCH "${CMAKE_MATCH_1}")
        endif()
    endif()
endif()

# Fallback to Debug if still not set
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
  set(BUILD_TYPE_SEARCH "Debug")
endif()

set(ARCH_BUILD_DIR /build/Android/)
set(ARCH_OUTPUT_DIR ${ARCH_BUILD_DIR}${BUILD_TYPE_SEARCH}/${ANDROID_ABI})

#find_package(Vulkan REQUIRED)

include(../../cmake/CommonBuildParameters.cmake)
