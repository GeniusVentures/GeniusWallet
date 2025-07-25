include(../cmake/CommonOverrideFlags.cmake)

# Project-level configuration.
cmake_minimum_required(VERSION 3.18)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded" CACHE STRING "Use /MT for static runtime" FORCE)
project(genius_wallet LANGUAGES CXX)

# ******************** Add non-flutter / breaking dependencies under this if  
if(NOT CMAKE_SKIP_THIRD_PARTY)

  # Define build configuration option.
  #set(CMAKE_BUILD_TYPE "Release")
  get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  message("CMAKE ARGS: $ENV{CMAKE_ARGUMENTS}")
# Parse CMAKE_ARGUMENTS environment variable if present
if(DEFINED ENV{CMAKE_ARGUMENTS})
    # Split the arguments string into a list
    string(REPLACE " " ";" CMAKE_ARG_LIST "$ENV{CMAKE_ARGUMENTS}")
    
    # Process each argument
    foreach(ARG IN LISTS CMAKE_ARG_LIST)
        # Check if it's a -D argument (variable definition)
        if(ARG MATCHES "^-D(.+)=(.+)$")
            set(VAR_NAME "${CMAKE_MATCH_1}")
            set(VAR_VALUE "${CMAKE_MATCH_2}")
            
            # Set the variable in the cache
            set(${VAR_NAME} "${VAR_VALUE}" CACHE STRING "From CMAKE_ARGUMENTS" FORCE)
            
            # Special handling for CMAKE_BUILD_TYPE
            if(VAR_NAME STREQUAL "CMAKE_BUILD_TYPE")
                    set(CMAKE_BUILD_TYPE "${VAR_VALUE}" CACHE STRING "Flutter build mode" FORCE)
                    set(BUILD_TYPE_SEARCH "${VAR_VALUE}")
            endif()
        endif()
    endforeach()
    
    # Optional: Log what was processed
    message(STATUS "Processed CMAKE_ARGUMENTS: $ENV{CMAKE_ARGUMENTS}")
endif()

  # Fallback to Debug if still not set
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
    set(BUILD_TYPE_SEARCH "Debug")
  endif()
  
  if(CMAKE_BUILD_TYPE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Profile" "Release")
  endif()

  # if(IS_MULTICONFIG)
  #   set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
  #     CACHE STRING "" FORCE)
  #     set(CMAKE_BUILD_TYPE "$ENV{CONFIGURATION}" CACHE STRING "Build type for single-config compatibility" FORCE)
  # else()
  #   if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  #     set(CMAKE_BUILD_TYPE "Debug" CACHE
  #       STRING "Flutter build mode" FORCE)
  #     set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
  #       "Debug" "Profile" "Release")
  #   endif()
  # endif()
endif()

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "genius_wallet")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)

set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")

set(ARCH_BUILD_DIR /build/Windows/)
set(ARCH_OUTPUT_DIR ${ARCH_BUILD_DIR}${CMAKE_BUILD_TYPE})
set(ARCH_RELEASE_OUTPUT_DIR ${ARCH_BUILD_DIR}${CMAKE_BUILD_TYPE})

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
message("Build Type: ${CMAKE_BUILD_TYPE}")
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")

  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set_property(TARGET ${TARGET} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreadedDebug")
    target_compile_definitions(${TARGET} PRIVATE
      $<$<CONFIG:Debug>:_ITERATOR_DEBUG_LEVEL=2>)
  else()
    set_property(TARGET ${TARGET} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded")
    target_compile_definitions(${TARGET} PRIVATE
      $<$<CONFIG:Release>:_ITERATOR_DEBUG_LEVEL=0>)
  endif()
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)

# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done instead of making a separate bundle (as on Linux)
# so that building and running from within Visual Studio will work.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")

# Make the "install" step default, as it's required to run.
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)


