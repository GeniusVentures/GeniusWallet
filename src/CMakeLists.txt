
cmake_minimum_required(VERSION 3.4.1)  
set(CMAKE_VERBOSE_MAKEFILE on)

include(../cmake/Utilities.cmake)
include(../cmake/CommonCompilerOptions.cmake)


set(THIRDPARTY_RELEASE_DIR ${THIRDPARTY_DIR}/${ARCH_OUTPUT_DIR})


add_library(walletcore STATIC IMPORTED)
set_target_properties(walletcore PROPERTIES 
    INTERFACE_INCLUDE_DIRECTORIES ${THIRDPARTY_RELEASE_DIR}/wallet-core/include/TrustWalletCore
    IMPORTED_LOCATION ${THIRDPARTY_RELEASE_DIR}/wallet-core/lib/libTrustWalletCore.a
)

add_library(wallet_core_rust STATIC IMPORTED)
set_target_properties(wallet_core_rust PROPERTIES 
    IMPORTED_LOCATION ${THIRDPARTY_RELEASE_DIR}/wallet-core/lib/libwallet_core_rs.a
)
add_library(wallet_core_trezor STATIC IMPORTED)
set_target_properties(wallet_core_trezor PROPERTIES 
    IMPORTED_LOCATION ${THIRDPARTY_RELEASE_DIR}/wallet-core/lib/libTrezorCrypto.a
)
add_library(protobuf_lib STATIC IMPORTED)
set_target_properties(protobuf_lib PROPERTIES 
    IMPORTED_LOCATION ${THIRDPARTY_RELEASE_DIR}/grpc/lib/libprotobuf.a
)
add_library(protobuf_lite_lib STATIC IMPORTED)
set_target_properties(protobuf_lite_lib PROPERTIES 
    IMPORTED_LOCATION ${THIRDPARTY_RELEASE_DIR}/grpc/lib/libprotobuf-lite.a
)
add_library(protoc_lib STATIC IMPORTED)
set_target_properties(protoc_lib PROPERTIES 
    IMPORTED_LOCATION ${THIRDPARTY_RELEASE_DIR}/grpc/lib/libprotoc.a
)
add_library(zlib STATIC IMPORTED)
set_target_properties(zlib PROPERTIES 
    IMPORTED_LOCATION ${THIRDPARTY_RELEASE_DIR}/grpc/lib/libz.a
)


add_library( 
    GeniusWallet
    SHARED
    null.cpp
)

if(CMAKE_SYSTEM_NAME STREQUAL "Android")
    find_library(log-lib log)
    target_link_libraries( GeniusWallet ${log-lib})
endif()

TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE( GeniusWallet walletcore)
target_link_libraries( GeniusWallet 
wallet_core_rust
wallet_core_trezor
protobuf_lib
)