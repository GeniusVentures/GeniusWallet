cmake_minimum_required(VERSION 3.4.1)  
set(CMAKE_VERBOSE_MAKEFILE on)

#project(twal)

add_library( 
    WalletCore23
    SHARED
    ${WALLET_CORE_WRAPPER_DIR}/lala.cpp
    )
target_include_directories(
    WalletCore23
    PUBLIC
    ${WALLET_CORE_LIB_DIR}/include/TrustWalletCore
)
target_link_libraries( WalletCore23
    ${WALLET_CORE_LIB_DIR}/lib/libTrustWalletCore.so
    #${WALLET_CORE_LIB_DIR}/libprotobuf.a
    
)