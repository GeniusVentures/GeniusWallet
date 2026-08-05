# Project-level configuration.
cmake_minimum_required(VERSION 3.18)
project(genius_wallet LANGUAGES CXX)

# The prebuilt native deps (GeniusSDK, TrustWalletCore, thirdparty) ship only a static
# release-CRT (/MT) build, even in their "Debug" package, and windows/runner links them
# whole-archive into the .exe. A stock /MTd debug runner therefore fails with LNK1319.
# Force /MT in every config, and drop /RTC1, whose run-time checks require the debug CRT.
# The matching _DEBUG removal lives in APPLY_STANDARD_SETTINGS below -- both are needed.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded" CACHE STRING "" FORCE)
foreach(FLAG_VAR CMAKE_CXX_FLAGS_DEBUG CMAKE_C_FLAGS_DEBUG)
    string(REGEX REPLACE "/RTC1" "" ${FLAG_VAR} "${${FLAG_VAR}}")
endforeach()

if(DEFINED ENV{CMAKE_ARGUMENTS})
    set(CMAKE_ARGUMENTS_RAW "$ENV{CMAKE_ARGUMENTS}")
    string(STRIP "${CMAKE_ARGUMENTS_RAW}" CMAKE_ARGUMENTS_RAW)
    if(CMAKE_ARGUMENTS_RAW MATCHES "^\".*\"$")
        string(LENGTH "${CMAKE_ARGUMENTS_RAW}" CMAKE_ARGUMENTS_LEN)
        math(EXPR CMAKE_ARGUMENTS_END "${CMAKE_ARGUMENTS_LEN} - 2")
        string(SUBSTRING "${CMAKE_ARGUMENTS_RAW}" 1 "${CMAKE_ARGUMENTS_END}" CMAKE_ARGUMENTS_RAW)
        string(STRIP "${CMAKE_ARGUMENTS_RAW}" CMAKE_ARGUMENTS_RAW)
    endif()
    # Split the arguments string into a list
    string(REPLACE " " ";" CMAKE_ARG_LIST "${CMAKE_ARGUMENTS_RAW}")

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

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "genius_wallet")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
    set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
endif()
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
    STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

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
function(APPLY_STANDARD_SETTINGS TARGET)
    target_compile_features(${TARGET} PUBLIC cxx_std_17)
    target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
    target_compile_options(${TARGET} PRIVATE /EHsc)
    target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
    # Flutter's template defines _DEBUG here in Debug config. We deliberately do not:
    # _DEBUG makes the STL request the debug CRT (libcpmtd, _CrtDbgReport) and sets
    # _ITERATOR_DEBUG_LEVEL=2, both of which conflict with the /MT release-CRT prebuilt
    # native deps we must link (see the runtime-library note at the top of this file).
    # This only affects the C++ layer -- Dart JIT/hot reload are unaffected by _DEBUG.
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")


# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)
if(TARGET clipboard_plugin)
    target_compile_options(clipboard_plugin PRIVATE /wd"4189")
    target_include_directories(${BINARY_NAME} PRIVATE "${FLUTTER_MANAGED_DIR}/ephemeral/.plugin_symlinks/clipboard")
endif()

# Removing _DEBUG from APPLY_STANDARD_SETTINGS above only covers targets that call it.
# Some plugins (clipboard, for one) inline Flutter's boilerplate and hard-code
# _DEBUG in their own CMakeLists inside the pub cache, which we cannot edit and which
# `pub get` would overwrite anyway. Sweep every target defined above and strip the
# define, so the entire C++ layer agrees with the /MT release-CRT prebuilts. Must run
# after generated_plugins.cmake, once all targets exist.
function(STRIP_DEBUG_DEFINE_RECURSE DIR)
    get_property(DIR_TARGETS DIRECTORY "${DIR}" PROPERTY BUILDSYSTEM_TARGETS)
    foreach(TGT ${DIR_TARGETS})
        get_target_property(TGT_TYPE ${TGT} TYPE)
        # INTERFACE/UTILITY targets have no compile definitions to strip.
        if(NOT TGT_TYPE STREQUAL "INTERFACE_LIBRARY" AND NOT TGT_TYPE STREQUAL "UTILITY")
            get_target_property(TGT_DEFS ${TGT} COMPILE_DEFINITIONS)
            if(TGT_DEFS)
                # Anchored so NDEBUG and _ITERATOR_DEBUG_LEVEL=N are left alone.
                list(FILTER TGT_DEFS EXCLUDE REGEX "^\\$<\\$<CONFIG:Debug>:_DEBUG>$")
                list(FILTER TGT_DEFS EXCLUDE REGEX "^_DEBUG$")
                set_target_properties(${TGT} PROPERTIES COMPILE_DEFINITIONS "${TGT_DEFS}")
            endif()
        endif()
    endforeach()
    get_property(SUBDIRS DIRECTORY "${DIR}" PROPERTY SUBDIRECTORIES)
    foreach(SUBDIR ${SUBDIRS})
        STRIP_DEBUG_DEFINE_RECURSE("${SUBDIR}")
    endforeach()
endfunction()
STRIP_DEBUG_DEFINE_RECURSE("${CMAKE_CURRENT_SOURCE_DIR}")

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

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

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
