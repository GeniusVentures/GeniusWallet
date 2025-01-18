# Project-level configuration.
set(ARCHS "x86_64" CACHE STRING "Default build for OSX is only x86_64 until boost can build universal image")
# Set OSX specific runtime options
set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "OSX Architectures")
cmake_minimum_required(VERSION 3.18)
project(runner LANGUAGES CXX)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -arch x86_64")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -arch x86_64")
# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "genius_wallet")

# The unique GTK application identifier for this application. See:
# https://wiki.gnome.org/HowDoI/ChooseApplicationID
set(APPLICATION_ID "com.example.genius_wallet")


set(ARCH_OUTPUT_DIR /build/OSX/${CMAKE_BUILD_TYPE})

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

