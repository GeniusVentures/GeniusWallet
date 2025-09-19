#!/bin/bash

# Default values
BUILD_TYPE="Release"
BUILD_MODE="--release"
EXTRA_ARGS=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        --debug)
            #BUILD_TYPE="Debug"
            BUILD_MODE="--debug"
            ;;
        *)
            EXTRA_ARGS="$EXTRA_ARGS $arg -v"
            ;;
    esac
done

# Detect host platform
OS="$(uname -s)"
case "$OS" in
    Linux*)     PLATFORM="linux";;
    Darwin*)    PLATFORM="macos";;
    CYGWIN*|MINGW*|MSYS*) PLATFORM="windows";;
    *)          echo "Unsupported platform: $OS"; exit 1;;
esac

export CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=$BUILD_TYPE -DGENIUS_DEPENDENCY_BRANCH=TestNet-Phase-3.1 -DBRANCH_IS_TAG=ON"

# Generate tokens
if command -v quicktype >/dev/null 2>&1; then
    ./tools/generate_tokens.sh
else
    echo "quicktype is not installed. Skipping generate_tokens.sh."
fi


# Build for detected platform
flutter build $PLATFORM $EXTRA_ARGS $BUILD_MODE
