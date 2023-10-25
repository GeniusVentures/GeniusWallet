
cmake_minimum_required(VERSION 3.4.1)  
set(CMAKE_VERBOSE_MAKEFILE on)

MACRO (TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE target)
  IF (WIN32)
    FOREACH (arg IN LISTS ARGN)
      SET_TARGET_PROPERTIES(
        ${target} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:${lib}"
      )
    ENDFOREACH ()
  ELSE ()
    IF (APPLE)
      SET(LINK_FLAGS "-Wl,-all_load")
      SET(UNDO_FLAGS "-Wl,-noall_load")
    ELSE ()
      SET(LINK_FLAGS "-Wl,--whole-archive")
      SET(UNDO_FLAGS "-Wl,--no-whole-archive")
    ENDIF ()
    TARGET_LINK_LIBRARIES(${target} ${LINK_FLAGS} ${ARGN} ${UNDO_FLAGS})
  ENDIF ()
ENDMACRO ()
# --------------------------------------------------------
# define third party directory
if (NOT DEFINED THIRDPARTY_DIR)
  if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../../thirdparty/README.md")
    message("Setting default third party directory")
    set(THIRDPARTY_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../thirdparty")
    ## get absolute path
    #cmake_path(SET THIRDPARTY_DIR NORMALIZE "${THIRDPARTY_DIR}") # Doesn't work in Cmake 3.18 (Android SDK's installed version here)
  else()
    message( FATAL_ERROR "Cannot find thirdparty directory required to build" )
  endif()
endif()

set(WALLET_CORE_LIB_DIR ${THIRDPARTY_DIR}/build/Android/Release)

find_library(log-lib log)

add_library(walletcore STATIC IMPORTED)
set_target_properties(walletcore PROPERTIES 
    INTERFACE_INCLUDE_DIRECTORIES ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/include/TrustWalletCore
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/lib/libTrustWalletCore.a
)

add_library(wallet_core_rust STATIC IMPORTED)
set_target_properties(wallet_core_rust PROPERTIES 
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/lib/libwallet_core_rs.a
)
add_library(wallet_core_trezor STATIC IMPORTED)
set_target_properties(wallet_core_trezor PROPERTIES 
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/lib/libTrezorCrypto.a
)
add_library(protobuf_lib STATIC IMPORTED)
set_target_properties(protobuf_lib PROPERTIES 
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/grpc/lib/libprotobuf.a
)
add_library(protobuf_lite_lib STATIC IMPORTED)
set_target_properties(protobuf_lite_lib PROPERTIES 
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/grpc/lib/libprotobuf-lite.a
)
add_library(protoc_lib STATIC IMPORTED)
set_target_properties(protoc_lib PROPERTIES 
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/grpc/lib/libprotoc.a
)
add_library(zlib STATIC IMPORTED)
set_target_properties(zlib PROPERTIES 
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/grpc/lib/libz.a
)

#include(AndroidNdkModules)
#android_ndk_import_module_cpufeatures()

add_library( 
    GeniusWallet
    SHARED
    null.cpp
)


target_link_libraries( GeniusWallet ${log-lib})
TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE( GeniusWallet walletcore)
target_link_libraries( GeniusWallet 
wallet_core_rust
wallet_core_trezor
protobuf_lib
)