include(../cmake/CommonOverrideFlags.cmake)

# Project-level configuration.
cmake_minimum_required(VERSION 3.18)
project(runner LANGUAGES C CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "genius_wallet")

# The unique GTK application identifier for this application. See:
# https://wiki.gnome.org/HowDoI/ChooseApplicationID
set(APPLICATION_ID "com.example.genius_wallet")


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

set(BUILD_TYPE_SEARCH ${CMAKE_BUILD_TYPE})
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
                if(VAR_VALUE STREQUAL "RelWithDebInfo")
                    set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "Profile flags" FORCE)
                    set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "Profile flags" FORCE)
                    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "Release flags" FORCE)
                    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "Release flags" FORCE)
                    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "Debug flags" FORCE)
                    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "Debug flags" FORCE)
                    set(BUILD_TYPE_SEARCH "RelWithDebInfo")
                else()
                    set(CMAKE_BUILD_TYPE "${VAR_VALUE}" CACHE STRING "Flutter build mode" FORCE)
                    set(BUILD_TYPE_SEARCH "${VAR_VALUE}")
                endif()
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

set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Profile" "Release")

if(NOT ABI_SUBFOLDER_NAME)
    if(NOT ARCH)
        # Use CMAKE_HOST_SYSTEM_PROCESSOR as it's more reliable for native builds
        # For cross-compilation, CMAKE_SYSTEM_PROCESSOR should be set correctly
        set(ARCH ${CMAKE_SYSTEM_PROCESSOR})

        # Normalize architecture names
        if(ARCH MATCHES "(x86_64|amd64|AMD64)")
            set(ARCH "x86_64")
        elseif(ARCH MATCHES "(aarch64|arm64|ARM64)")
            set(ARCH "aarch64")
        else()
            message(WARNING "Unknown Linux architecture: ${ARCH}, using as-is")
        endif()

        set(ARCH "${ARCH}" CACHE STRING "Target arch")
    endif()

    set(ABI_SUBFOLDER_NAME "/${ARCH}" CACHE STRING "ABI subdirectory")
endif()

set(ARCH_BUILD_DIR /build/Linux/)
set(ARCH_OUTPUT_DIR ${ARCH_BUILD_DIR}${BUILD_TYPE_SEARCH}${ABI_SUBFOLDER_NAME})
set(ARCH_RELEASE_OUTPUT_DIR ${ARCH_BUILD_DIR}Release${ABI_SUBFOLDER_NAME})
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

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})
include(../cmake/CommonBuildParameters.cmake)

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Define the application target. To change its name, change BINARY_NAME above,
# not the value here, or `flutter run` will no longer work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
    "main.cc"
    "my_application.cc"
    "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

if(NOT CMAKE_SKIP_THIRD_PARTY)
    target_link_libraries(${BINARY_NAME} PUBLIC GeniusWallet)
endif()

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# Only the install-generated bundle's copy of the executable will launch
# correctly, since the resources must in the right relative locations. To avoid
# people trying to run the unbundled copy, put it in a subdirectory instead of
# the default top-level location.
set_target_properties(${BINARY_NAME}
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/intermediates_do_not_run"
)

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)

# === Installation ===
# By default, "installing" just makes a relocatable bundle in the build
# directory.
set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/bundle")

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

# Start with a clean build bundle directory every time.
install(CODE "
  file(REMOVE_RECURSE \"${BUILD_BUNDLE_DIR}/\")
  "    COMPONENT Runtime)

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
    COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
    COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)

if(NOT CMAKE_SKIP_THIRD_PARTY)
    install(TARGETS GeniusWallet DESTINATION "${INSTALL_BUNDLE_LIB_DIR}" COMPONENT Runtime)
endif()


foreach(bundled_library ${PLUGIN_BUNDLED_LIBRARIES})
    install(FILES "${bundled_library}"
        DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
        COMPONENT Runtime)
endforeach(bundled_library)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  "    COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
    DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
if(NOT CMAKE_BUILD_TYPE MATCHES "Debug")
    install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
        COMPONENT Runtime)
endif()
