cmake_minimum_required(VERSION 3.4.1)  
set(CMAKE_VERBOSE_MAKEFILE on)

add_library( 
    WalletCoreFlutter
    INTERFACE
)
#add_library( 
#    WalletCoreFLut
#    STATIC
#    ${WALLET_CORE_WRAPPER_DIR}/lala.cpp
#    )
#target_include_directories(
#    WalletCore23
#    PUBLIC
#    ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/include/TrustWalletCore
#)
target_link_libraries( WalletCoreFlutter
    INTERFACE
    ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/lib/libTrustWalletCore.a  
)