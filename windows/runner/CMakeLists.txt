cmake_minimum_required(VERSION 3.18)
project(runner LANGUAGES CXX)

if(CMAKE_BUILD_TYPE)
    set(ARCH_OUTPUT_DIR /build/Windows/${CMAKE_BUILD_TYPE})
else()
    set(ARCH_OUTPUT_DIR /build/Windows/${BUILD_TYPE_SEARCH})
endif()
set(ARCH_RELEASE_OUTPUT_DIR /build/Windows/Release)

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

if(MSVC)
    target_compile_options(${BINARY_NAME} PRIVATE
        $<$<CONFIG:Release>:/Zi>
        $<$<CONFIG:Profile>:/Zi>
    )

    target_link_options(${BINARY_NAME} PRIVATE
        $<$<CONFIG:Release>:/DEBUG:FULL>
        $<$<CONFIG:Profile>:/DEBUG:FULL>
        $<$<CONFIG:Release>:/INCREMENTAL:NO>
        $<$<CONFIG:Profile>:/INCREMENTAL:NO>
        $<$<CONFIG:Release>:/OPT:REF>
        $<$<CONFIG:Profile>:/OPT:REF>
        $<$<CONFIG:Release>:/OPT:ICF>
        $<$<CONFIG:Profile>:/OPT:ICF>
    )

    set_target_properties(${BINARY_NAME} PROPERTIES
        COMPILE_PDB_NAME "${BINARY_NAME}"
        COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner/$<CONFIG>"
        PDB_NAME "${BINARY_NAME}"
        PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner/$<CONFIG>"
    )
endif()

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
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_W_TYPE(${BINARY_NAME} PRIVATE TrustWalletCore sgns::GeniusSDK)
target_link_libraries(${BINARY_NAME} PRIVATE
  wallet_core_rs
  TrezorCrypto
  ws2_32 userenv ntdll
 )

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)
