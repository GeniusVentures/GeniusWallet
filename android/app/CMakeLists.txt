cmake_minimum_required(VERSION 3.4.1)  
set(CMAKE_VERBOSE_MAKEFILE on)

#project(twal)

add_library( 
    WalletCore
    SHARED
    ${WALLET_CORE_WRAPPER_DIR}/lala.cpp
    )
target_include_directories(
    WalletCore
    PUBLIC
    ${WALLET_CORE_LIB_DIR}/include/TrustWalletCore
)
target_link_libraries( WalletCore
    ${WALLET_CORE_LIB_DIR}/build/libTrustWalletCore.a
    #${WALLET_CORE_LIB_DIR}/libprotobuf.a
    
)