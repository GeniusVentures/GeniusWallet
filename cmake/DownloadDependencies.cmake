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
    elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
        set(${PLATFORM_NAME} "iOS" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
    endif()
endfunction()

# Function to get all required Android ABIs
function(get_android_abis ABIS_VAR)
    if(CMAKE_SYSTEM_NAME STREQUAL "Android")
        # Check if ABIs are explicitly defined
        if(DEFINED ANDROID_ABIS)
            set(${ABIS_VAR} ${ANDROID_ABIS} PARENT_SCOPE)
        elseif(DEFINED CMAKE_ANDROID_ARCH_ABI)
            # For Flutter, this might be set
            set(${ABIS_VAR} ${CMAKE_ANDROID_ARCH_ABI} PARENT_SCOPE)
        else()
            # Default to common ABIs for Flutter
            set(${ABIS_VAR} "arm64-v8a" "armeabi-v7a" PARENT_SCOPE)
        endif()
    else()
        set(${ABIS_VAR} "" PARENT_SCOPE)
    endif()
endfunction()

# Function to check if a dependency is release-only
function(is_release_only_dependency DEP_NAME RESULT_VAR)
    # List of dependencies that only have Release builds
    set(RELEASE_ONLY_DEPS
        "zkLLVM"
        # Add more release-only dependencies here as needed
    )
    
    if(${DEP_NAME} IN_LIST RELEASE_ONLY_DEPS)
        set(${RESULT_VAR} TRUE PARENT_SCOPE)
    else()
        set(${RESULT_VAR} FALSE PARENT_SCOPE)
    endif()
endfunction()

# Function to check if dependency exists
function(check_dependency_exists DEP_NAME DEP_DIR EXISTS_VAR)
    get_platform_dir_name(PLATFORM_NAME)
    
    # Check if this is a release-only dependency
    is_release_only_dependency(${DEP_NAME} IS_RELEASE_ONLY)
    
    # Determine which build type to check
    if(IS_RELEASE_ONLY)
        set(CHECK_BUILD_TYPE "Release")
    else()
        set(CHECK_BUILD_TYPE ${CMAKE_BUILD_TYPE})
        if(NOT CHECK_BUILD_TYPE)
            set(CHECK_BUILD_TYPE "Release")
        endif()
    endif()

    # For Android, check all required ABIs
    if(CMAKE_SYSTEM_NAME STREQUAL "Android")
        get_android_abis(REQUIRED_ABIS)
        set(ALL_EXIST TRUE)
        
        foreach(ABI ${REQUIRED_ABIS})
            set(CHECK_PATH "${DEP_DIR}/build/${PLATFORM_NAME}/${CHECK_BUILD_TYPE}/${ABI}")
            if(NOT EXISTS ${CHECK_PATH})
                set(ALL_EXIST FALSE)
                message(STATUS "${DEP_NAME} missing for ABI: ${ABI}")
                break()
            else()
                message(STATUS "${DEP_NAME} found for ABI: ${ABI}")
            endif()
        endforeach()
        
        set(${EXISTS_VAR} ${ALL_EXIST} PARENT_SCOPE)
    else()
        # Non-Android logic
        set(CHECK_PATHS
            "${DEP_DIR}/build/${PLATFORM_NAME}/${CHECK_BUILD_TYPE}"
            "${DEP_DIR}/${ARCH_OUTPUT_DIR}"  # Legacy path format
        )

        foreach(CHECK_PATH ${CHECK_PATHS})
            if(EXISTS ${CHECK_PATH})
                set(${EXISTS_VAR} TRUE PARENT_SCOPE)
                if(IS_RELEASE_ONLY AND NOT CMAKE_BUILD_TYPE STREQUAL "Release")
                    message(STATUS "${DEP_NAME} found at: ${CHECK_PATH} (Release-only dependency)")
                else()
                    message(STATUS "${DEP_NAME} found at: ${CHECK_PATH}")
                endif()
                return()
            endif()
        endforeach()

        set(${EXISTS_VAR} FALSE PARENT_SCOPE)
    endif()
endfunction()

# Function to download and extract a dependency
function(download_dependency DEP_NAME)
    cmake_parse_arguments(ARG "" "BRANCH;BUILD_TYPE;EXTRACT_TO;FORCE" "" ${ARGN})

    # Set defaults
    if(NOT ARG_BRANCH)
        set(ARG_BRANCH "develop")
    endif()
    
    # Check if this is a release-only dependency
    is_release_only_dependency(${DEP_NAME} IS_RELEASE_ONLY)
    
    if(NOT ARG_BUILD_TYPE)
        if(IS_RELEASE_ONLY)
            set(ARG_BUILD_TYPE "Release")
        else()
            set(ARG_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
            if(NOT ARG_BUILD_TYPE)
                set(ARG_BUILD_TYPE "Release")
            endif()
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
            message(STATUS "${DEP_NAME} already exists for all required configurations, skipping download")
            return()
        endif()
    endif()

    # Get platform name
    get_platform_dir_name(PLATFORM_NAME)

    # Determine the release tag format
    if(DEFINED BRANCH_IS_TAG AND BRANCH_IS_TAG)
        # For tags, use the tag name directly
        set(RELEASE_TAG "${ARG_BRANCH}")
        message(STATUS "Using Git tag format: ${ARG_BRANCH}")
    else()
        # For branches, use the platform-branch-buildtype format
        set(RELEASE_TAG "${PLATFORM_NAME}-${ARG_BRANCH}-${ARG_BUILD_TYPE}")
    endif()
    
    # GitHub repository information
    set(GITHUB_REPO "GeniusVentures/${DEP_NAME}")

    # Handle Android multi-ABI downloads
    if(CMAKE_SYSTEM_NAME STREQUAL "Android")
        get_android_abis(REQUIRED_ABIS)
        
        message(STATUS "----------------------------------------")
        message(STATUS "Downloading ${DEP_NAME} for Android")
        message(STATUS "  Required ABIs: ${REQUIRED_ABIS}")
        if(DEFINED BRANCH_IS_TAG AND BRANCH_IS_TAG)
            message(STATUS "  Tag: ${ARG_BRANCH}")
        else()
            message(STATUS "  Branch: ${ARG_BRANCH}")
            message(STATUS "  Build Type: ${ARG_BUILD_TYPE}")
        endif()
        if(IS_RELEASE_ONLY)
            message(STATUS "  Note: This is a release-only dependency")
        endif()
        message(STATUS "----------------------------------------")
        
        foreach(ABI ${REQUIRED_ABIS})
            # Check if this specific ABI already exists
            set(ABI_PATH "${ARG_EXTRACT_TO}/build/${PLATFORM_NAME}/${ARG_BUILD_TYPE}/${ABI}")
            if(EXISTS ${ABI_PATH} AND NOT ARG_FORCE)
                message(STATUS "${DEP_NAME} for ${ABI} already exists, skipping")
                continue()
            endif()
            
            set(ARCHIVE_NAME "${PLATFORM_NAME}-${ABI}-${ARG_BUILD_TYPE}.tar.gz")
            set(RELEASE_URL "https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/${ARCHIVE_NAME}")
            set(ARCHIVE_PATH "${CMAKE_BINARY_DIR}/${DEP_NAME}-${ARCHIVE_NAME}")
            
            message(STATUS "Downloading ${DEP_NAME} for ABI: ${ABI}")
            message(STATUS "  URL: ${RELEASE_URL}")
            
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
                message(FATAL_ERROR "Failed to download ${DEP_NAME} for ${ABI}: ${ERROR_MESSAGE}")
            endif()
            
            # Create extraction directory
            file(MAKE_DIRECTORY ${ARG_EXTRACT_TO})
            
            # Extract the archive
            message(STATUS "Extracting ${DEP_NAME} for ${ABI} to ${ARG_EXTRACT_TO}...")
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
                WORKING_DIRECTORY ${ARG_EXTRACT_TO}
                RESULT_VARIABLE EXTRACT_RESULT
                OUTPUT_VARIABLE EXTRACT_OUTPUT
                ERROR_VARIABLE EXTRACT_ERROR
            )
            
            if(NOT EXTRACT_RESULT EQUAL 0)
                message(FATAL_ERROR "Failed to extract ${DEP_NAME} archive for ${ABI}: ${EXTRACT_ERROR}")
            endif()
            
            # Clean up archive
            file(REMOVE ${ARCHIVE_PATH})
            
            message(STATUS "${DEP_NAME} for ${ABI} successfully downloaded and extracted")
        endforeach()
    else()
        # Non-Android download logic
        if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND ARCH)
            set(ARCHIVE_NAME "${PLATFORM_NAME}-${ARCH}-${ARG_BUILD_TYPE}.tar.gz")
        else()
            set(ARCHIVE_NAME "${PLATFORM_NAME}-${ARG_BUILD_TYPE}.tar.gz")
        endif()
        
        set(RELEASE_URL "https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/${ARCHIVE_NAME}")
        set(ARCHIVE_PATH "${CMAKE_BINARY_DIR}/${DEP_NAME}-${ARCHIVE_NAME}")
        
        message(STATUS "----------------------------------------")
        message(STATUS "Downloading ${DEP_NAME}")
        message(STATUS "  Platform: ${PLATFORM_NAME}")
        if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND ARCH)
            message(STATUS "  Architecture: ${ARCH}")
        endif()
        if(DEFINED BRANCH_IS_TAG AND BRANCH_IS_TAG)
            message(STATUS "  Tag: ${ARG_BRANCH}")
        else()
            message(STATUS "  Branch: ${ARG_BRANCH}")
            message(STATUS "  Build Type: ${ARG_BUILD_TYPE}")
        endif()
        if(IS_RELEASE_ONLY)
            message(STATUS "  Note: This is a release-only dependency")
        endif()
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
            message(FATAL_ERROR "Failed to download ${DEP_NAME}: ${ERROR_MESSAGE}")
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
    endif()
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
    
    # Check if this is a release-only dependency
    is_release_only_dependency(${DEP_NAME} IS_RELEASE_ONLY)

    # Determine dependency directory
    get_filename_component(PARENT_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
    get_filename_component(PARENT_DIR ${PARENT_DIR} DIRECTORY)
    set(DEP_DIR "${PARENT_DIR}/${DEP_NAME}")

    # Download if needed
    download_dependency(${DEP_NAME} BRANCH ${ARG_BRANCH} BUILD_TYPE ${ARG_BUILD_TYPE})

    # Set the directory variable for the dependency
    get_platform_dir_name(PLATFORM_NAME)
    
    # For release-only dependencies, always use Release path
    if(IS_RELEASE_ONLY)
        set(USE_BUILD_TYPE "Release")
    else()
        set(USE_BUILD_TYPE ${CMAKE_BUILD_TYPE})
    endif()

    set(${ARG_VAR_PREFIX}_DIR "${DEP_DIR}" CACHE PATH "${DEP_NAME} directory" FORCE)

    if(IS_RELEASE_ONLY AND NOT CMAKE_BUILD_TYPE STREQUAL "Release")
        message(STATUS "${DEP_NAME} directory set to: ${${ARG_VAR_PREFIX}_DIR} (Release-only dependency)")
    else()
        message(STATUS "${DEP_NAME} directory set to: ${${ARG_VAR_PREFIX}_DIR}")
    endif()
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

# Function to detect current Git branch and determine dependency branch
function(get_dependency_branch BRANCH_VAR)
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
            # If we're on main branch, use main for dependencies, otherwise use develop
            if(GIT_BRANCH STREQUAL "main")
                set(${BRANCH_VAR} "main" PARENT_SCOPE)
                message(STATUS "Detected Git branch: ${GIT_BRANCH}, using 'main' for dependencies")
            else()
                set(${BRANCH_VAR} "develop" PARENT_SCOPE)
                message(STATUS "Detected Git branch: ${GIT_BRANCH}, using 'develop' for dependencies")
            endif()
        else()
            set(${BRANCH_VAR} "develop" PARENT_SCOPE)
            message(STATUS "Could not detect Git branch, defaulting to: develop")
        endif()
    else()
        set(${BRANCH_VAR} "develop" PARENT_SCOPE)
        message(STATUS "Git not found, defaulting to branch: develop")
    endif()
endfunction()

# Function to resolve dependency-specific branch override
function(resolve_dependency_branch DEP_NAME DEFAULT_BRANCH RESULT_VAR)
    # Convert dependency name to uppercase for variable names
    string(TOUPPER ${DEP_NAME} DEP_NAME_UPPER)
    
    # Check for dependency-specific override variable
    set(DEP_BRANCH_VAR "GENIUS_${DEP_NAME_UPPER}_BRANCH")
    
    if(DEFINED ${DEP_BRANCH_VAR})
        set(${RESULT_VAR} ${${DEP_BRANCH_VAR}} PARENT_SCOPE)
        message(STATUS "Using dependency-specific branch for ${DEP_NAME}: ${${DEP_BRANCH_VAR}} (from ${DEP_BRANCH_VAR})")
    else()
        set(${RESULT_VAR} ${DEFAULT_BRANCH} PARENT_SCOPE)
        if(DEFINED GENIUS_DEPENDENCY_BRANCH)
            message(STATUS "Using global branch for ${DEP_NAME}: ${DEFAULT_BRANCH} (from GENIUS_DEPENDENCY_BRANCH)")
        else()
            message(STATUS "Using default branch for ${DEP_NAME}: ${DEFAULT_BRANCH}")
        endif()
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
            # Auto-detect from Git and apply main/develop logic
            get_dependency_branch(ARG_BRANCH)
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
        if(CMAKE_SYSTEM_NAME STREQUAL "Android")
            get_android_abis(REQUIRED_ABIS)
            message(STATUS "Android ABIs: ${REQUIRED_ABIS}")
        endif()
        message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
        if(DEFINED BRANCH_IS_TAG AND BRANCH_IS_TAG)
            message(STATUS "Tag: ${ARG_BRANCH}")
        else()
            message(STATUS "Branch: ${ARG_BRANCH}")
        endif()
        message(STATUS "Dependencies: ${DEPENDENCIES}")
        message(STATUS "========================================")

        foreach(DEP ${DEPENDENCIES})
            # Resolve dependency-specific branch override
            resolve_dependency_branch(${DEP} ${ARG_BRANCH} DEP_BRANCH)
            setup_dependency(${DEP} BRANCH ${DEP_BRANCH})
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
# 8. Override specific dependencies with different branches:
#    set(GENIUS_DEPENDENCY_BRANCH "TestNet-Phase-3.1")
#    set(GENIUS_SUPERGENIUS_BRANCH "develop")
#    set(GENIUS_ZKLLVM_BRANCH "main")
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(SuperGenius GeniusSDK zkLLVM thirdparty)
#    # SuperGenius uses "develop", zkLLVM uses "main", GeniusSDK and thirdparty use "TestNet-Phase-3.1"
#
# 9. Download custom/external dependencies:
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(thirdparty MyCustomLib AnotherRepo)
#
# 10. Android multi-ABI support:
#    if(ANDROID)
#        set(ANDROID_ABIS "arm64-v8a" "armeabi-v7a")
#    endif()
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(SuperGenius GeniusSDK zkLLVM thirdparty)
#
# 11. Tag-based dependencies:
#    set(GENIUS_DEPENDENCY_BRANCH "v1.0.0")
#    set(BRANCH_IS_TAG ON)
#    include(cmake/DownloadDependencies.cmake)
#    download_project_dependencies(SuperGenius GeniusSDK zkLLVM thirdparty)
#
# Variables:
#   GENIUS_SKIP_DEPENDENCY_DOWNLOAD - Set to ON to skip all downloads
#   GENIUS_DEPENDENCY_BRANCH - Override the auto-detected Git branch for all dependencies
#   GENIUS_<DEPENDENCY>_BRANCH - Override branch for specific dependency (e.g., GENIUS_SUPERGENIUS_BRANCH, GENIUS_GENIUSSDK_BRANCH, GENIUS_ZKLLVM_BRANCH, GENIUS_THIRDPARTY_BRANCH)
#   BRANCH_IS_TAG - Set to ON when GENIUS_DEPENDENCY_BRANCH is a tag (not a branch)
#   ANDROID_ABIS - List of Android ABIs to download (defaults to arm64-v8a and armeabi-v7a)
#
# Note: Dependencies are downloaded from https://github.com/GeniusVentures/{DEP_NAME}/releases
# Note: When on 'main' branch, dependencies from 'main' are used. For all other branches, 'develop' dependencies are used.
# Note: For Android builds, the script will download dependencies for all specified ABIs automatically.
# Note: When BRANCH_IS_TAG is ON, the release tag format is just the tag name (e.g., "v1.0.0") instead of "Platform-Branch-BuildType"
# Note: Dependency-specific branch overrides take precedence over GENIUS_DEPENDENCY_BRANCH
#
# Example CMake command with dependency-specific overrides:
# CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=TestNet-Phase-3.1 -DGENIUS_SUPERGENIUS_BRANCH=develop -DGENIUS_ZKLLVM_BRANCH=main -DBRANCH_IS_TAG=ON"