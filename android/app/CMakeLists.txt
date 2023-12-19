
cmake_minimum_required(VERSION 3.4.1)  
set(CMAKE_VERBOSE_MAKEFILE on)

set(ARCH_OUTPUT_DIR /build/Android/Release/${ANDROID_ABI})

set(FFI_LAYER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../src")
set(FFI_LIB_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/ffi")
add_subdirectory(${FFI_LAYER_DIR} ${FFI_LIB_OUT_DIR})

