
cmake_minimum_required(VERSION 3.4.1)  
set(CMAKE_VERBOSE_MAKEFILE on)

include(../cmake/Utilities.cmake)
include(../cmake/CommonCompilerOptions.cmake)

if(CMAKE_SYSTEM_NAME STREQUAL "Android")
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
endif()


set(THIRDPARTY_RELEASE_DIR ${THIRDPARTY_DIR}/${ARCH_OUTPUT_DIR})

set(WALLET_CORE_LIB_NANE TrustWalletCore)
set(WALLET_CORE_LIB_NANE ${WALLET_CORE_LIB_NANE} PARENT_SCOPE)
set(WALLET_RUST_LIB_NAME wallet_core_rs)
set(WALLET_RUST_LIB_NAME ${WALLET_RUST_LIB_NAME} PARENT_SCOPE)
set(WALLET_TREZOR_LIB_NAME TrezorCrypto)
set(WALLET_TREZOR_LIB_NAME ${WALLET_TREZOR_LIB_NAME} PARENT_SCOPE)
set(PROTOBUF_LIB_NAME protobuf)
set(PROTOBUF_LIB_NAME ${PROTOBUF_LIB_NAME} PARENT_SCOPE)


find_library(walletcore HINTS ${THIRDPARTY_RELEASE_DIR}/wallet-core/lib NAMES ${WALLET_CORE_LIB_NANE} lib${WALLET_CORE_LIB_NANE})
add_library(${WALLET_CORE_LIB_NANE} INTERFACE)
target_link_libraries(${WALLET_CORE_LIB_NANE} INTERFACE ${walletcore})

find_library(wallet_core_rust HINTS ${THIRDPARTY_RELEASE_DIR}/wallet-core/lib NAMES ${WALLET_RUST_LIB_NAME} lib${WALLET_RUST_LIB_NAME})
add_library(${WALLET_RUST_LIB_NAME} INTERFACE)
target_link_libraries(${WALLET_RUST_LIB_NAME} INTERFACE ${wallet_core_rust})

find_library(wallet_core_trezor HINTS ${THIRDPARTY_RELEASE_DIR}/wallet-core/lib NAMES ${WALLET_TREZOR_LIB_NAME} lib${WALLET_TREZOR_LIB_NAME})
add_library(${WALLET_TREZOR_LIB_NAME} INTERFACE)
target_link_libraries(${WALLET_TREZOR_LIB_NAME} INTERFACE ${wallet_core_trezor})

find_library(protobuf_lib HINTS ${THIRDPARTY_RELEASE_DIR}/grpc/lib NAMES ${PROTOBUF_LIB_NAME} lib${PROTOBUF_LIB_NAME})
add_library(${PROTOBUF_LIB_NAME} INTERFACE)
target_link_libraries(${PROTOBUF_LIB_NAME} INTERFACE ${protobuf_lib})

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
    add_library( 
        GeniusWallet
        SHARED
        null.cpp
    )
    if (SET_NAME_UNIX_FORCE)
        message(WARNING "Forcing file to be name libGeniusWallet.so")
        set_target_properties(GeniusWallet PROPERTIES SUFFIX ".so")
        set_target_properties(GeniusWallet PROPERTIES PREFIX "lib")
    endif()


    if(CMAKE_SYSTEM_NAME STREQUAL "Android")
        find_library(LOG_LIB log)
        target_link_libraries( GeniusWallet ${LOG_LIB})
    endif()

    TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE( GeniusWallet ${walletcore})
    target_link_libraries(GeniusWallet 
    ${wallet_core_rust}
    ${wallet_core_trezor}
    ${protobuf_lib}
    )
endif()
