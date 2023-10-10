
cmake_minimum_required(VERSION 3.4.1)  
set(CMAKE_VERBOSE_MAKEFILE on)

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

target_link_libraries( GeniusWallet
${log-lib}
-Wl,--whole-archive walletcore -Wl,--no-whole-archive
wallet_core_rust
wallet_core_trezor
protobuf_lib
)