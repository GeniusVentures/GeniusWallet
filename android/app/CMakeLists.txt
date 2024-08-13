
cmake_minimum_required(VERSION 3.18)  
set(CMAKE_VERBOSE_MAKEFILE on)

set(CMAKE_BUILD_TYPE Release)
set(ARCH_OUTPUT_DIR /build/Android/${CMAKE_BUILD_TYPE}/${ANDROID_ABI})

find_package(Vulkan REQUIRED)

set(FFI_LAYER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../src")
set(FFI_LIB_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/ffi")
add_subdirectory(${FFI_LAYER_DIR} ${FFI_LIB_OUT_DIR})

