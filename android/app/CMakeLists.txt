cmake_minimum_required(VERSION 3.18)

# Fallback to Debug if still not set
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
elseif(CMAKE_BUILD_TYPE STREQUAL "release")
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Flutter build mode" FORCE)
endif()

set(BUILD_TYPE_SEARCH ${CMAKE_BUILD_TYPE})

set(ARCH_BUILD_DIR /build/Android/)
set(ARCH_OUTPUT_DIR ${ARCH_BUILD_DIR}${BUILD_TYPE_SEARCH}/${ANDROID_ABI})
set(ARCH_RELEASE_OUTPUT_DIR ${ARCH_BUILD_DIR}Release/${ANDROID_ABI})

foreach(_ANDROID_LIB android log)
    if(NOT TARGET android::${_ANDROID_LIB})
        add_library(android::${_ANDROID_LIB} INTERFACE IMPORTED GLOBAL)
        set_target_properties(android::${_ANDROID_LIB} PROPERTIES IMPORTED_LIBNAME "${_ANDROID_LIB}")
    endif()
endforeach()

include(../../cmake/CommonBuildParameters.cmake)
