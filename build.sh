#!/bin/bash

# Default values
BUILD_TYPE="Release"
BUILD_MODE="--release"
EXTRA_ARGS=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        --debug)
            BUILD_TYPE="Debug"
            BUILD_MODE="--debug"
            ;;
        *)
            EXTRA_ARGS="$EXTRA_ARGS $arg"
            ;;
    esac
done

export CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=$BUILD_TYPE"
./tools/generate_tokens.sh
flutter build $EXTRA_ARGS $BUILD_MODE