cmake_minimum_required(VERSION 3.4.1)  
set(CMAKE_VERBOSE_MAKEFILE on)

add_library(walletcore STATIC IMPORTED)
set_target_properties(walletcore PROPERTIES 
    INTERFACE_INCLUDE_DIRECTORIES ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/include/TrustWalletCore
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/lib/libTrustWalletCore.a
)

add_library(wallet_core_rust STATIC IMPORTED)
set_target_properties(wallet_core_rust PROPERTIES 
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/lib/libwallet_core_rs.a
)

add_library( 
    walletWrapper
    SHARED
    ${PRJ_WRAPPER_DIR}/native_wallet.cpp

)
target_link_libraries( walletWrapper
    walletcore
    wallet_core_rust
)