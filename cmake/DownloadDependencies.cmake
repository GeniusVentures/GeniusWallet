# DownloadDependencies.cmake
# Generic dependency downloader for GeniusVentures projects
# Can be included in any CMakeLists.txt file

# Function to determine platform directory name
function(get_platform_dir_name PLATFORM_NAME)
    if(CMAKE_SYSTEM_NAME STREQUAL "Android")
        set(${PLATFORM_NAME} "Android" PARENT_SCOPE)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        if(CMAKE_OSX_SYSROOT MATCHES "iphoneos|iphonesimulator")
            set(${PLATFORM_NAME} "iOS" PARENT_SCOPE)
        else()
            set(${PLATFORM_NAME} "OSX" PARENT_SCOPE)
        endif()
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(${PLATFORM_NAME} "Linux" PARENT_SCOPE)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        set(${PLATFORM_NAME} "Windows" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
    endif()
endfunction()

# Function to check if dependency exists
function(check_dependency_exists DEP_NAME DEP_DIR EXISTS_VAR)
    get_platform_dir_name(PLATFORM_NAME)

    # Check various possible locations
    set(CHECK_PATHS
        "${DEP_DIR}/build/${PLATFORM_NAME}/${CMAKE_BUILD_TYPE}"
        "${DEP_DIR}/build/${PLATFORM_NAME}/Release"  # Fallback to Release
        "${DEP_DIR}/${ARCH_OUTPUT_DIR}"  # Legacy path format
    )

    # Add Android ABI path if needed
    if(CMAKE_SYSTEM_NAME STREQUAL "Android" AND ANDROID_ABI)
        set(CHECK_PATHS
            "${DEP_DIR}/build/${PLATFORM_NAME}/${CMAKE_BUILD_TYPE}/${ANDROID_ABI}"
            "${DEP_DIR}/build/${PLATFORM_NAME}/Release/${ANDROID_ABI}"
            ${CHECK_PATHS}
        )
    endif()

    foreach(CHECK_PATH ${CHECK_PATHS})
        if(EXISTS ${CHECK_PATH})
            set(${EXISTS_VAR} TRUE PARENT_SCOPE)
            message(STATUS "${DEP_NAME} found at: ${CHECK_PATH}")
            return()
        endif()
    endforeach()

    set(${EXISTS_VAR} FALSE PARENT_SCOPE)
endfunction()

# Function to download and extract a dependency
function(download_dependency DEP_NAME)
    cmake_parse_arguments(ARG "" "BRANCH;BUILD_TYPE;EXTRACT_TO;FORCE" "" ${ARGN})

    # Set defaults
    if(NOT ARG_BRANCH)
        set(ARG_BRANCH "develop")
    endif()
    if(NOT ARG_BUILD_TYPE)
        set(ARG_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
        if(NOT ARG_BUILD_TYPE)
            set(ARG_BUILD_TYPE "Release")
        endif()
    endif()
    if(NOT ARG_EXTRACT_TO)
        # Default to parent directory structure
        get_filename_component(PARENT_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
        get_filename_component(PARENT_DIR ${PARENT_DIR} DIRECTORY)
        set(ARG_EXTRACT_TO "${PARENT_DIR}/${DEP_NAME}")
    endif()

    # Check if dependency already exists (unless FORCE is specified)
    if(NOT ARG_FORCE)
        check_dependency_exists(${DEP_NAME} ${ARG_EXTRACT_TO} DEP_EXISTS)
        if(DEP_EXISTS)
            message(STATUS "${DEP_NAME} already exists, skipping download")
            return()
        endif()
    endif()

    # Get platform name
    get_platform_dir_name(PLATFORM_NAME)

    # Construct archive name and release tag
    if(CMAKE_SYSTEM_NAME STREQUAL "Android" AND ANDROID_ABI)
        set(ARCHIVE_NAME "${PLATFORM_NAME}-${ANDROID_ABI}-${ARG_BRANCH}-${ARG_BUILD_TYPE}.tar.gz")
        set(RELEASE_TAG "${PLATFORM_NAME}-${ANDROID_ABI}-${ARG_BRANCH}-${ARG_BUILD_TYPE}")
    else()
        set(ARCHIVE_NAME "${PLATFORM_NAME}-${ARG_BRANCH}-${ARG_BUILD_TYPE}.tar.gz")
        set(RELEASE_TAG "${PLATFORM_NAME}-${ARG_BRANCH}-${ARG_BUILD_TYPE}")
    endif()

    # GitHub repository information
    set(GITHUB_REPO "GeniusVentures/${DEP_NAME}")
    set(RELEASE_URL "https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/${ARCHIVE_NAME}")
    set(ARCHIVE_PATH "${CMAKE_BINARY_DIR}/${DEP_NAME}-${ARCHIVE_NAME}")

    message(STATUS "----------------------------------------")
    message(STATUS "Downloading ${DEP_NAME}")
    message(STATUS "  Platform: ${PLATFORM_NAME}")
    message(STATUS "  Branch: ${ARG_BRANCH}")
    message(STATUS "  Build Type: ${ARG_BUILD_TYPE}")
    message(STATUS "  URL: ${RELEASE_URL}")
    message(STATUS "----------------------------------------")

    # Download the release
    file(DOWNLOAD
        ${RELEASE_URL}
        ${ARCHIVE_PATH}
        STATUS DOWNLOAD_STATUS
        SHOW_PROGRESS
        TIMEOUT 300  # 5 minute timeout
    )

    list(GET DOWNLOAD_STATUS 0 DOWNLOAD_RESULT)
    list(GET DOWNLOAD_STATUS 1 ERROR_MESSAGE)

    if(NOT DOWNLOAD_RESULT EQUAL 0)
        # Try with different build type as fallback
        if(ARG_BUILD_TYPE STREQUAL "Debug")
            message(WARNING "Failed to download Debug build, trying Release...")
            download_dependency(${DEP_NAME}
                BRANCH ${ARG_BRANCH}
                BUILD_TYPE "Release"
                EXTRACT_TO ${ARG_EXTRACT_TO}
                FORCE ${ARG_FORCE}
            )
            return()
        else()
            message(FATAL_ERROR "Failed to download ${DEP_NAME}: ${ERROR_MESSAGE}")
        endif()
    endif()

    # Create extraction directory
    file(MAKE_DIRECTORY ${ARG_EXTRACT_TO})

    # Extract the archive
    message(STATUS "Extracting ${DEP_NAME} to ${ARG_EXTRACT_TO}...")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
        WORKING_DIRECTORY ${ARG_EXTRACT_TO}
        RESULT_VARIABLE EXTRACT_RESULT
        OUTPUT_VARIABLE EXTRACT_OUTPUT
        ERROR_VARIABLE EXTRACT_ERROR
    )

    if(NOT EXTRACT_RESULT EQUAL 0)
        message(FATAL_ERROR "Failed to extract ${DEP_NAME} archive: ${EXTRACT_ERROR}")
    endif()

    # Clean up archive
    file(REMOVE ${ARCHIVE_PATH})

    message(STATUS "${DEP_NAME} successfully downloaded and extracted")
endfunction()

# Function to setup a dependency (check/download and set variables)
function(setup_dependency DEP_NAME)
    cmake_parse_arguments(ARG "" "BRANCH;BUILD_TYPE;VAR_PREFIX" "" ${ARGN})

    # Set defaults
    if(NOT ARG_BRANCH)
        set(ARG_BRANCH "develop")
    endif()
    if(NOT ARG_VAR_PREFIX)
        string(TOUPPER ${DEP_NAME} ARG_VAR_PREFIX)
    endif()

    # Determine dependency directory
    get_filename_component(PARENT_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
    get_filename_component(PARENT_DIR ${PARENT_DIR} DIRECTORY)
    set(DEP_DIR "${PARENT_DIR}/${DEP_NAME}")

    # Download if needed
    download_dependency(${DEP_NAME} BRANCH ${ARG_BRANCH} BUILD_TYPE ${ARG_BUILD_TYPE})

    # Set the directory variable for the dependency
    get_platform_dir_name(PLATFORM_NAME)
    if(CMAKE_SYSTEM_NAME STREQUAL "Android" AND ANDROID_ABI)
        set(${ARG_VAR_PREFIX}_DIR "${DEP_DIR}/build/${PLATFORM_NAME}/${CMAKE_BUILD_TYPE}/${ANDROID_ABI}" CACHE PATH "${DEP_NAME} directory" FORCE)
    else()
        set(${ARG_VAR_PREFIX}_DIR "${DEP_DIR}/build/${PLATFORM_NAME}/${CMAKE_BUILD_TYPE}" CACHE PATH "${DEP_NAME} directory" FORCE)
    endif()

    # Also check for Release as fallback
    if(NOT EXISTS ${${ARG_VAR_PREFIX}_DIR})
        if(CMAKE_SYSTEM_NAME STREQUAL "Android" AND ANDROID_ABI)
            set(${ARG_VAR_PREFIX}_DIR "${DEP_DIR}/build/${PLATFORM_NAME}/Release/${ANDROID_ABI}" CACHE PATH "${DEP_NAME} directory" FORCE)
        else()
            set(${ARG_VAR_PREFIX}_DIR "${DEP_DIR}/build/${PLATFORM_NAME}/Release" CACHE PATH "${DEP_NAME} directory" FORCE)
        endif()
    endif()

    message(STATUS "${DEP_NAME} directory set to: ${${ARG_VAR_PREFIX}_DIR}")
endfunction()

# Function to check if any dependencies need downloading
function(check_dependencies_needed DEPS RESULT_VAR)
    set(NEED_DOWNLOAD FALSE)

    foreach(DEP ${DEPS})
        # Determine dependency directory
        get_filename_component(PARENT_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
        get_filename_component(PARENT_DIR ${PARENT_DIR} DIRECTORY)
        set(DEP_DIR "${PARENT_DIR}/${DEP}")

        check_dependency_exists(${DEP} ${DEP_DIR} DEP_EXISTS)
        if(NOT DEP_EXISTS)
            set(NEED_DOWNLOAD TRUE)
            break()
        endif()
    endforeach()

    set(${RESULT_VAR} ${NEED_DOWNLOAD} PARENT_SCOPE)
endfunction()

# Function to detect current Git branch
function(get_git_branch BRANCH_VAR)
    find_package(Git QUIET)
    if(GIT_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_BRANCH
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
            RESULT_VARIABLE GIT_RESULT
        )
        if(GIT_RESULT EQUAL 0 AND GIT_BRANCH)
            set(${BRANCH_VAR} ${GIT_BRANCH} PARENT_SCOPE)
            message(STATUS "Detected Git branch: ${GIT_BRANCH}")
        else()
            set(${BRANCH_VAR} "develop" PARENT_SCOPE)
            message(STATUS "Could not detect Git branch, defaulting to: develop")
        endif()
    else()
        set(${BRANCH_VAR} "develop" PARENT_SCOPE)
        message(STATUS "Git not found, defaulting to branch: develop")
    endif()
endfunction()

# Main function to download project dependencies
function(download_project_dependencies)
    # Check if downloads are disabled
    if(DEFINED GENIUS_SKIP_DEPENDENCY_DOWNLOAD AND GENIUS_SKIP_DEPENDENCY_DOWNLOAD)
        message(STATUS "Dependency download skipped (GENIUS_SKIP_DEPENDENCY_DOWNLOAD is set)")
        return()
    endif()

    cmake_parse_arguments(ARG "" "BRANCH" "" ${ARGN})

    # Auto-detect branch if not specified
    if(NOT ARG_BRANCH)
        if(DEFINED GENIUS_DEPENDENCY_BRANCH)
            # Use override branch if specified
            set(ARG_BRANCH ${GENIUS_DEPENDENCY_BRANCH})
            message(STATUS "Using dependency branch from GENIUS_DEPENDENCY_BRANCH: ${ARG_BRANCH}")
        else()
            # Auto-detect from Git
            get_git_branch(ARG_BRANCH)
        endif()
    endif()

    # All remaining arguments are dependencies
    set(DEPENDENCIES ${ARG_UNPARSED_ARGUMENTS})

    if(NOT DEPENDENCIES)
        message(WARNING "No dependencies specified for download_project_dependencies()")
        return()
    endif()

    # Check if any downloads are needed
    check_dependencies_needed("${DEPENDENCIES}" NEED_DOWNLOADS)

    if(NEED_DOWNLOADS)
        get_platform_dir_name(PLATFORM_NAME)
        message(STATUS "========================================")
        message(STATUS "Downloading dependencies for ${PROJECT_NAME}")
        message(STATUS "Platform: ${PLATFORM_NAME}")
        message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
        message(STATUS "Branch: ${ARG_BRANCH}")
        message(STATUS "Dependencies: ${DEPENDENCIES}")
        message(STATUS "========================================")

        foreach(DEP ${DEPENDENCIES})
            setup_dependency(${DEP} BRANCH ${ARG_BRANCH})
        endforeach()
    else()
        message(STATUS "All dependencies are already present, skipping downloads")
    endif()
endfunction()

# Convenience wrapper for backward compatibility
function(download_all_genius_dependencies)
    message(DEPRECATION "download_all_genius_dependencies() is deprecated. Use download_project_dependencies() instead.")
    download_project_dependencies(${ARGN})
endfunction()

# Usage Examples:
#
# 1. GeniusWallet project (downloads SuperGenius, GeniusSDK, zkLLVM, thirdparty):
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(SuperGenius GeniusSDK zkLLVM thirdparty)
#
# 2. SuperGenius project (downloads zkLLVM, thirdparty):
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(zkLLVM thirdparty)
#
# 3. GeniusSDK project (downloads thirdparty, SuperGenius, zkLLVM):
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(thirdparty SuperGenius zkLLVM)
#
# 4. Download with specific branch:
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(BRANCH master thirdparty zkLLVM)
#
# 5. Download individual dependency:
#    include(cmake/DownloadDependencies.cmake)
#    download_dependency(thirdparty BRANCH develop BUILD_TYPE Debug)
#
# 6. Skip dependency downloads:
#    set(GENIUS_SKIP_DEPENDENCY_DOWNLOAD ON)
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(thirdparty zkLLVM)  # Will be skipped
#
# 7. Override auto-detected branch:
#    set(GENIUS_DEPENDENCY_BRANCH "master")
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(thirdparty zkLLVM)  # Will use master branch
#
# 8. Download custom/external dependencies:
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(thirdparty MyCustomLib AnotherRepo)
#
# Variables:
#   GENIUS_SKIP_DEPENDENCY_DOWNLOAD - Set to ON to skip all downloads
#   GENIUS_DEPENDENCY_BRANCH - Override the auto-detected Git branch
#
# Note: Dependencies are downloaded from https://github.com/GeniusVentures/{DEP_NAME}/releases
