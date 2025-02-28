cmake_minimum_required(VERSION 3.18)
project(runner LANGUAGES CXX)
include(../../cmake/CommonOverrideFlags.cmake)
include(../../cmake/Utilities.cmake)
include(../../cmake/CommonCompilerOptions.cmake)

# FLUTTER DEPENDENCIES ****************************************************

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
    "flutter_window.cpp"
    "main.cpp"
    "utils.cpp"
    "win32_window.cpp"
    "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
    "Runner.rc"
    "runner.exe.manifest"
)

include(../../cmake/CommonBuildParameters.cmake)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# **************************************************** FLUTTER DEPENDENCIES 


# *** Add all none flutter dependencies here:

if(NOT CMAKE_SKIP_THIRD_PARTY)

    # set(GTest_DIR "${THIRDPARTY_RELEASE_DIR}/GTest/lib/cmake/GTest")
    # set(GTest_INCLUDE_DIR "${THIRDPARTY_RELEASE_DIR}/GTest/include")
    # find_package(GTest CONFIG REQUIRED)
    # include_directories(${GTest_INCLUDE_DIR})

    TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_W_TYPE(${BINARY_NAME} PRIVATE TrustWalletCore sgns::GeniusSDK)
    target_link_libraries(${BINARY_NAME} PRIVATE
        wallet_core_rs
        TrezorCrypto
        ws2_32 userenv ntdll
    )

    set(ARCH_OUTPUT_DIR /build/Windows/${CMAKE_BUILD_TYPE})
    set(ARCH_OUTPUT_DIR_REL /build/Windows/Release)
    set(THIRDPARTY_RELEASE_DIR ${THIRDPARTY_DIR}${ARCH_OUTPUT_DIR})

    if(NOT DEFINED absl_DIR)
        set(absl_DIR "${THIRDPARTY_RELEASE_DIR}/grpc/lib/cmake/absl")
    endif()

    if(NOT DEFINED utf8_range_DIR)
        set(utf8_range_DIR "${THIRDPARTY_RELEASE_DIR}/grpc/lib/cmake/utf8_range")
    endif()

    # --------------------------------------------------------
    # Set config of protobuf project
    if(NOT DEFINED Protobuf_DIR)
        set(Protobuf_DIR "${THIRDPARTY_RELEASE_DIR}/grpc/cmake")
        set(Protobuf_INCLUDE_DIR "${THIRDPARTY_RELEASE_DIR}/grpc/include/google/protobuf")
        find_package(Protobuf CONFIG REQUIRED)
        include_directories(${Protobuf_INCLUDE_DIR})
    endif()

    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.20) # v142 toolset
        set(Boost_COMPILER "-vc142")
    else() # v143 toolset
        set(Boost_COMPILER "-vc143")
    endif()
endif()