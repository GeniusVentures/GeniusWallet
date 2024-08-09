cmake_minimum_required(VERSION 3.18)
project(runner LANGUAGES CXX)
include(../../cmake/Utilities.cmake)
include(../../cmake/CommonCompilerOptions.cmake)

set(ARCH_OUTPUT_DIR /build/Windows/${CMAKE_BUILD_TYPE})
set(THIRDPARTY_RELEASE_DIR ${THIRDPARTY_DIR}${ARCH_OUTPUT_DIR})

if(NOT DEFINED absl_DIR)
    set(absl_DIR "${THIRDPARTY_RELEASE_DIR}/grpc/lib/cmake/absl")
    set(absl_INCLUDE_DIR "${THIRDPARTY_RELEASE_DIR}/grpc/include/absl")
    find_package(absl CONFIG REQUIRED)
    include_directories(${absl_INCLUDE_DIR})
endif()

if(NOT DEFINED utf8_range_DIR)
    set(utf8_range_DIR "${THIRDPARTY_RELEASE_DIR}/grpc/lib/cmake/utf8_range")
    set(utf8_range_INCLUDE_DIR "${THIRDPARTY_RELEASE_DIR}/grpc/include")
    find_package(utf8_range CONFIG REQUIRED)
    include_directories(${utf8_range_INCLUDE_DIR})
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


set(FFI_LAYER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../src")
set(FFI_LIB_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/../ffi")
add_subdirectory(${FFI_LAYER_DIR} ${FFI_LIB_OUT_DIR})

#set(GTest_DIR "${THIRDPARTY_RELEASE_DIR}/GTest/lib/cmake/GTest")
#set(GTest_INCLUDE_DIR "${THIRDPARTY_RELEASE_DIR}/GTest/include")
#find_package(GTest CONFIG REQUIRED)
#include_directories(${GTest_INCLUDE_DIR})




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


TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_W_TYPE(${BINARY_NAME} PUBLIC ${WALLET_CORE_LIBRARY})
get_target_property(GeniusSDK_LIB_PATH sgns::GeniusSDK IMPORTED_LOCATION_DEBUG)
TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_W_TYPE(${BINARY_NAME} PUBLIC ${GeniusSDK_LIB_PATH})
target_link_libraries(${BINARY_NAME} PUBLIC 
${WALLET_CORE_RUST_LIBRARY} 
ws2_32 userenv ntdll
${WALLET_CORE_TREZOR_CRYPTO_LIBRARY}
protobuf::libprotobuf
absl::status
absl::statusor
absl::hash
absl::log
absl::cord
absl::raw_hash_set
absl::base
absl::strings
absl::synchronization
absl::log_internal_check_op
utf8_range::utf8_validity
#sgns::sgns_account
#sgns::GeniusSDK
)
#target_link_options(${BINARY_NAME} PRIVATE /WHOLEARCHIVE:sgns::GeniusSDK)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)