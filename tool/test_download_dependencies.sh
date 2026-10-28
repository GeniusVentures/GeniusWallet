#!/usr/bin/env bash
# Checks that check_dependency_exists() in cmake/DownloadDependencies.cmake
# tells an iOS device install apart from an arm64-simulator one, which share
# build/iOS/<type>. Needs only cmake.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/check.cmake" <<CMAKE
set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_BUILD_TYPE Release)
include("$repo/cmake/DownloadDependencies.cmake")

function(expect LABEL ABI WANT)
    set(ARCH "\${ABI}")
    if(ABI)
        set(ARCH_OUTPUT_DIR "build/iOS/Release/\${ABI}")
    else()
        set(ARCH_OUTPUT_DIR "build/iOS/Release")
    endif()
    check_dependency_exists(SuperGenius "$tmp/SuperGenius" GOT)
    if(NOT "\${GOT}" STREQUAL "\${WANT}")
        message(FATAL_ERROR "FAIL: \${LABEL}: expected \${WANT}, got \${GOT}")
    endif()
endfunction()

file(MAKE_DIRECTORY "$tmp/SuperGenius/build/iOS/Release/arm64-simulator/SuperGenius")
expect("simulator only, simulator build" arm64-simulator TRUE)
expect("simulator only, device build" "" FALSE)

file(MAKE_DIRECTORY "$tmp/SuperGenius/build/iOS/Release/SuperGenius")
expect("both, device build" "" TRUE)
expect("both, simulator build" arm64-simulator TRUE)

file(REMOVE_RECURSE "$tmp/SuperGenius/build/iOS/Release/arm64-simulator")
expect("device only, simulator build" arm64-simulator FALSE)
CMAKE

cmake -P "$tmp/check.cmake" > "$tmp/out.log" 2>&1 || { cat "$tmp/out.log"; exit 1; }
echo "test_download_dependencies.sh: PASSED"
