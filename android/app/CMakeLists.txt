
cmake_minimum_required(VERSION 3.18)
set(CMAKE_VERBOSE_MAKEFILE on)

set(BUILD_TYPE_SEARCH ${CMAKE_BUILD_TYPE})
# Read CMAKE_BUILD_TYPE from environment if passed via CMAKE_ARGUMENTS
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

set(ARCH_BUILD_DIR /build/Android/)
set(ARCH_OUTPUT_DIR ${ARCH_BUILD_DIR}${BUILD_TYPE_SEARCH}/${ANDROID_ABI})
set(ARCH_RELEASE_OUTPUT_DIR ${ARCH_BUILD_DIR}Release/${ANDROID_ABI})

#find_package(Vulkan REQUIRED)

include(../../cmake/CommonBuildParameters.cmake)
