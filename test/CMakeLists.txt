
cmake_minimum_required(VERSION 3.18)  
set(CMAKE_VERBOSE_MAKEFILE on)

if (MSVC)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_CURRENT_BINARY_DIR}/ffi)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG  ${CMAKE_CURRENT_BINARY_DIR}/ffi)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG  ${CMAKE_CURRENT_BINARY_DIR}/ffi)
endif (MSVC)


if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(SYSTEM_FOLDER "OSX")
else()
    set(SYSTEM_FOLDER ${CMAKE_SYSTEM_NAME})
endif()

set(SET_NAME_UNIX_FORCE TRUE)

set(ARCH_OUTPUT_DIR /build/${SYSTEM_FOLDER}/${CMAKE_BUILD_TYPE}/)

set(FFI_LAYER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../src")
set(FFI_LIB_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/ffi")
add_subdirectory(${FFI_LAYER_DIR} ${FFI_LIB_OUT_DIR})


if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    add_library( 
        GeniusWallet
        SHARED
        ../src/null.cpp
    )

    message(WARNING "Forcing file to be name libGeniusWallet.so")
    set_target_properties(GeniusWallet PROPERTIES SUFFIX ".so")
    set_target_properties(GeniusWallet PROPERTIES PREFIX "lib")


    TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE(GeniusWallet ${WALLET_CORE_LIB_NANE})
    target_link_libraries(GeniusWallet  
    ${WALLET_RUST_LIB_NAME} 
    ws2_32 userenv ntdll
    ${WALLET_TREZOR_LIB_NAME}
    ${PROTOBUF_LIB_NAME}
    )
endif()
