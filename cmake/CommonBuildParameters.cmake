include(${CMAKE_CURRENT_LIST_DIR}/CommonOverrideFlags.cmake)

if(NOT CMAKE_SKIP_THIRD_PARTY)
    cmake_minimum_required(VERSION 3.18)
    set(CMAKE_VERBOSE_MAKEFILE on)

    include(${CMAKE_CURRENT_LIST_DIR}/Utilities.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/DownloadDependencies.cmake)
    
        # Download dependencies specific to GeniusWallet
    # The function will auto-detect the current Git branch
    download_project_dependencies(
        SuperGenius
        GeniusSDK
        zkLLVM
        thirdparty
    )
    
    
    include(${CMAKE_CURRENT_LIST_DIR}/CommonCompilerOptions.cmake)
    if(CMAKE_SYSTEM_NAME STREQUAL "Android")
        set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
        set(ABI_SUBFOLDER_NAME "/${ANDROID_ABI}")
    endif()

    set(THIRDPARTY_BUILD_DIR ${THIRDPARTY_DIR}/${ARCH_OUTPUT_DIR})
    set(ZKLLVM_BUILD_DIR ${ZKLLVM_DIR}/${ARCH_RELEASE_OUTPUT_DIR})
    message(STATUS "BUILD DIR: ${THIRDPARTY_BUILD_DIR}")
    message(STATUS "ZKLLVM_BUILD_DIR DIR: ${ZKLLVM_BUILD_DIR}")
    set(WALLET_CORE_DIR "${THIRDPARTY_BUILD_DIR}/wallet-core" CACHE PATH "Path to WalletCore install folder")
    set(WALLET_CORE_INCLUDE_DIR "${WALLET_CORE_DIR}/include" CACHE PATH "Path to WalletCore include folder")
    set(WALLET_CORE_LIB_DIR "${WALLET_CORE_DIR}/lib" CACHE PATH "Path to WalletCore lib folder")
    set(WALLET_CORE_LIBRARY ${WALLET_CORE_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}TrustWalletCore${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE PATH "Path to WalletCore main lib")
    set(WALLET_CORE_TREZOR_CRYPTO_LIBRARY ${WALLET_CORE_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}TrezorCrypto${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE PATH "Path to TrezorCrypto lib")
    set(WALLET_CORE_RUST_LIBRARY ${WALLET_CORE_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}wallet_core_rs${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE PATH "Path to WalletCore rust lib")

    add_library(TrustWalletCore STATIC IMPORTED)
    set_target_properties(TrustWalletCore PROPERTIES IMPORTED_LOCATION ${WALLET_CORE_LIBRARY})
    add_library(wallet_core_rs STATIC IMPORTED)
    set_target_properties(wallet_core_rs PROPERTIES IMPORTED_LOCATION ${WALLET_CORE_RUST_LIBRARY})
    add_library(TrezorCrypto STATIC IMPORTED)
    set_target_properties(TrezorCrypto PROPERTIES IMPORTED_LOCATION ${WALLET_CORE_TREZOR_CRYPTO_LIBRARY})

    # Set Boost Versions
    set(BOOST_MAJOR_VERSION "1" CACHE STRING "Boost Major Version")
    set(BOOST_MINOR_VERSION "85" CACHE STRING "Boost Minor Version")
    set(BOOST_PATCH_VERSION "0" CACHE STRING "Boost Patch Version")

    # convenience settings
    set(BOOST_VERSION "${BOOST_MAJOR_VERSION}.${BOOST_MINOR_VERSION}.${BOOST_PATCH_VERSION}")
    set(BOOST_VERSION_3U "${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_PATCH_VERSION}")
    set(BOOST_VERSION_2U "${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}")

    if(NOT DEFINED absl_DIR)
        set(absl_DIR "${THIRDPARTY_BUILD_DIR}/grpc/lib/cmake/absl")
    endif()

    if(NOT DEFINED utf8_range_DIR)
        set(utf8_range_DIR "${THIRDPARTY_BUILD_DIR}/grpc/lib/cmake/utf8_range")
    endif()

    # protobuf project
    if(NOT DEFINED Protobuf_DIR)
        if (NOT DEFINED PROTOBUF_CONFIG_LOCATION)
            set(PROTOBUF_CONFIG_LOCATION "/grpc/lib/cmake/protobuf")
        endif()
        message("Protobuf directory: ${THIRDPARTY_BUILD_DIR}${PROTOBUF_CONFIG_LOCATION}")
        set(Protobuf_DIR "${THIRDPARTY_BUILD_DIR}${PROTOBUF_CONFIG_LOCATION}")
    endif()

    if(NOT DEFINED Protobuf_INCLUDE_DIR)
        set(Protobuf_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/grpc/include/google/protobuf")
    endif()

    set(OPENSSL_DIR "${THIRDPARTY_BUILD_DIR}/openssl/build" CACHE PATH "Path to OpenSSL install folder")
    set(OPENSSL_USE_STATIC_LIBS ON CACHE BOOL "OpenSSL use static libs")
    set(OPENSSL_MSVC_STATIC_RT ON CACHE BOOL "OpenSSL use static RT")
    set(OPENSSL_ROOT_DIR "${OPENSSL_DIR}" CACHE PATH "Path to OpenSSL install root folder")
    set(OPENSSL_INCLUDE_DIR "${OPENSSL_DIR}/include" CACHE PATH "Path to OpenSSL include folder")
    set(OPENSSL_LIBRARIES "${OPENSSL_DIR}/lib" CACHE PATH "Path to OpenSSL lib folder")
    set(OPENSSL_CRYPTO_LIBRARY ${OPENSSL_LIBRARIES}/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE PATH "Path to OpenSSL crypto lib")
    set(OPENSSL_SSL_LIBRARY ${OPENSSL_LIBRARIES}/libssl${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE PATH "Path to OpenSSL ssl lib")
    find_package(OpenSSL REQUIRED)

    # rocksdb
    message(STATUS "ROCKSDB ${THIRDPARTY_BUILD_DIR}")
    set(RocksDB_DIR "${THIRDPARTY_BUILD_DIR}/rocksdb/lib/cmake/rocksdb")
    set(RocksDB_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/rocksdb/include")
    find_package(RocksDB CONFIG REQUIRED)

    #Find VUlkan
    if(APPLE)
        if(IOS)
            # Settings specifically for iOS
            set(Vulkan_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/moltenvk/build/include")
            set(Vulkan_LIBRARY "${THIRDPARTY_BUILD_DIR}/moltenvk/build/lib/MoltenVK.xcframework")
        else()
            # Settings for macOS
            set(Vulkan_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/moltenvk/build/include/")
            set(Vulkan_LIBRARY "${THIRDPARTY_BUILD_DIR}/moltenvk/build/lib/MoltenVK.xcframework")
        endif()
    endif()
    find_package(Vulkan)

    if(NOT TARGET Vulkan::Vulkan)
        if(NOT DEFINED $ENV{VULKAN_SDK})
            set(ENV{VULKAN_SDK} "${THIRDPARTY_BUILD_DIR}/Vulkan-Loader")
        endif()

        find_package(Vulkan REQUIRED)
    endif()

    # MNN
    set(MNN_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/MNN/include")
    set(MNN_DIR "${THIRDPARTY_BUILD_DIR}/MNN/lib/cmake/MNN")
    find_package(MNN CONFIG REQUIRED)
    include_directories(${MNN_INCLUDE_DIR})

    # stb
    include_directories(${THIRDPARTY_BUILD_DIR}/stb/include)

    # Microsoft.GSL
    set(GSL_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/Microsoft.GSL/include")

    # fmt
    set(fmt_DIR "${THIRDPARTY_BUILD_DIR}/fmt/lib/cmake/fmt")
    set(fmt_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/fmt/include")
    find_package(fmt CONFIG REQUIRED)

    # spdlog v1.4.2
    set(spdlog_DIR "${THIRDPARTY_BUILD_DIR}/spdlog/lib/cmake/spdlog")
    set(spdlog_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/spdlog/include")
    find_package(spdlog CONFIG REQUIRED)
    add_compile_definitions("SPDLOG_FMT_EXTERNAL")

    # soralog
    set(soralog_DIR "${THIRDPARTY_BUILD_DIR}/soralog/lib/cmake/soralog")
    set(soralog_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/soralog/include")
    find_package(soralog CONFIG REQUIRED)

    # yaml-cpp
    set(yaml-cpp_DIR "${THIRDPARTY_BUILD_DIR}/yaml-cpp/lib/cmake/yaml-cpp")
    set(yaml-cpp_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/yaml-cpp/include")
    find_package(yaml-cpp CONFIG REQUIRED)

    #  tsl_hat_trie
    set(tsl_hat_trie_DIR "${THIRDPARTY_BUILD_DIR}/tsl_hat_trie/lib/cmake/tsl_hat_trie")
    set(tsl_hat_trie_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/tsl_hat_trie/include")
    find_package(tsl_hat_trie CONFIG REQUIRED)

    # Boost.DI
    set(Boost.DI_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/Boost.DI/include")
    set(Boost.DI_DIR "${THIRDPARTY_BUILD_DIR}/Boost.DI/lib/cmake/Boost.DI")
    find_package(Boost.DI CONFIG REQUIRED)

    # Boost should be loaded before libp2p v0.1.2
    # Boost project
    set(_BOOST_ROOT "${THIRDPARTY_BUILD_DIR}/boost/build")
    message(STATUS "BOOST ROOT ${_BOOST_ROOT}")
    set(Boost_LIB_DIR "${_BOOST_ROOT}/lib")
    set(Boost_INCLUDE_DIR "${_BOOST_ROOT}/include/boost-${BOOST_VERSION_2U}")
    set(Boost_DIR "${Boost_LIB_DIR}/cmake/Boost-${BOOST_VERSION}")
    set(boost_headers_DIR "${Boost_LIB_DIR}/cmake/boost_headers-${BOOST_VERSION}")
    set(boost_random_DIR "${Boost_LIB_DIR}/cmake/boost_random-${BOOST_VERSION}")
    set(boost_system_DIR "${Boost_LIB_DIR}/cmake/boost_system-${BOOST_VERSION}")
    set(boost_filesystem_DIR "${Boost_LIB_DIR}/cmake/boost_filesystem-${BOOST_VERSION}")
    set(boost_program_options_DIR "${Boost_LIB_DIR}/cmake/boost_program_options-${BOOST_VERSION}")
    set(boost_date_time_DIR "${Boost_LIB_DIR}/cmake/boost_date_time-${BOOST_VERSION}")
    set(boost_regex_DIR "${Boost_LIB_DIR}/cmake/boost_regex-${BOOST_VERSION}")
    set(boost_atomic_DIR "${Boost_LIB_DIR}/cmake/boost_atomic-${BOOST_VERSION}")
    set(boost_chrono_DIR "${Boost_LIB_DIR}/cmake/boost_chrono-${BOOST_VERSION}")
    set(boost_container_DIR "${Boost_LIB_DIR}/cmake/boost_container-${BOOST_VERSION}")
    set(boost_log_DIR "${Boost_LIB_DIR}/cmake/boost_log-${BOOST_VERSION}")
    set(boost_log_setup_DIR "${Boost_LIB_DIR}/cmake/boost_log_setup-${BOOST_VERSION}")
    set(boost_thread_DIR "${Boost_LIB_DIR}/cmake/boost_thread-${BOOST_VERSION}")
    set(boost_unit_test_framework_DIR "${Boost_LIB_DIR}/cmake/boost_unit_test_framework-${BOOST_VERSION}")
    set(boost_json_DIR "${Boost_LIB_DIR}/cmake/boost_json-${BOOST_VERSION}")
    set(Boost_USE_MULTITHREADED ON)
    set(Boost_USE_STATIC_LIBS ON)
    set(Boost_NO_SYSTEM_PATHS ON)
    option(Boost_USE_STATIC_RUNTIME "Use static runtimes" ON)

    if(NOT DEFINED Boost_COMPILER)
        set(Boost_COMPILER "-clang")
    endif()

    option(SGNS_STACKTRACE_BACKTRACE "Use BOOST_STACKTRACE_USE_BACKTRACE in stacktraces, for POSIX" OFF)

    if(SGNS_STACKTRACE_BACKTRACE)
        add_definitions(-DSGNS_STACKTRACE_BACKTRACE=1)

        if(BACKTRACE_INCLUDE)
            add_definitions(-DBOOST_STACKTRACE_BACKTRACE_INCLUDE_FILE=${BACKTRACE_INCLUDE})
        endif()
    endif()

    # header only libraries must not be added here
    find_package(Boost REQUIRED COMPONENTS date_time filesystem random regex system thread log log_setup program_options unit_test_framework json)

    # SQLiteModernCpp project
    set(SQLiteModernCpp_ROOT_DIR "${THIRDPARTY_BUILD_DIR}/SQLiteModernCpp")
    set(SQLiteModernCpp_DIR "${SQLiteModernCpp_ROOT_DIR}/lib/cmake/SQLiteModernCpp")
    set(SQLiteModernCpp_LIB_DIR "${SQLiteModernCpp_ROOT_DIR}/lib")
    set(SQLiteModernCpp_INCLUDE_DIR "${SQLiteModernCpp_ROOT_DIR}/include")

    # SQLiteModernCpp project
    set(sqlite3_ROOT_DIR "${THIRDPARTY_BUILD_DIR}/sqlite3")
    set(sqlite3_DIR "${sqlite3_ROOT_DIR}/lib/cmake/sqlite3")
    set(sqlite3_LIB_DIR "${sqlite3_ROOT_DIR}/lib")
    set(sqlite3_INCLUDE_DIR "${sqlite3_ROOT_DIR}/include")

    # cares
    set(c-ares_DIR "${THIRDPARTY_BUILD_DIR}/cares/lib/cmake/c-ares" CACHE PATH "Path to c-ares install folder")
    set(c-ares_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/cares/include" CACHE PATH "Path to c-ares include folder")

    # libp2p
    set(libp2p_DIR "${THIRDPARTY_BUILD_DIR}/libp2p/lib/cmake/libp2p")
    set(libp2p_LIBRARY_DIR "${THIRDPARTY_BUILD_DIR}/libp2p/lib")
    set(libp2p_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/libp2p/include")
    find_package(libp2p CONFIG REQUIRED)

    # Find and include cares if libp2p have not included it
    if(NOT TARGET c-ares::cares_static)
        find_package(c-ares CONFIG REQUIRED)
    endif()

    # ipfs-lite-cpp
    set(ipfs-lite-cpp_DIR "${THIRDPARTY_BUILD_DIR}/ipfs-lite-cpp/lib/cmake/ipfs-lite-cpp")
    set(ipfs-lite-cpp_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/ipfs-lite-cpp/include")
    set(ipfs-lite-cpp_LIB_DIR "${THIRDPARTY_BUILD_DIR}/ipfs-lite-cpp/lib")
    set(CBOR_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/ipfs-lite-cpp/include/deps/tinycbor/src")
    find_package(ipfs-lite-cpp CONFIG REQUIRED)

    # ipfs-pubsub
    set(ipfs-pubsub_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/ipfs-pubsub/include")
    set(ipfs-pubsub_DIR "${THIRDPARTY_BUILD_DIR}/ipfs-pubsub/lib/cmake/ipfs-pubsub")
    find_package(ipfs-pubsub CONFIG REQUIRED)

    # ipfs-bitswap-cpp
    set(ipfs-bitswap-cpp_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/ipfs-bitswap-cpp/include")
    set(ipfs-bitswap-cpp_DIR "${THIRDPARTY_BUILD_DIR}/ipfs-bitswap-cpp/lib/cmake/ipfs-bitswap-cpp")
    find_package(ipfs-bitswap-cpp CONFIG REQUIRED)

    # ed25519
    set(ed25519_DIR "${THIRDPARTY_BUILD_DIR}/ed25519/lib/cmake/ed25519")
    set(ed25519_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/ed25519/include")
    find_package(ed25519 CONFIG REQUIRED)

    # sr25519-donna
    set(sr25519-donna_DIR "${THIRDPARTY_BUILD_DIR}/sr25519-donna/lib/cmake/sr25519-donna")
    set(sr25519-donna_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/sr25519-donna/include")
    find_package(sr25519-donna CONFIG REQUIRED)

    # Set RapidJSON config path
    set(RapidJSON_DIR "${THIRDPARTY_BUILD_DIR}/rapidjson/lib/cmake/RapidJSON")
    set(RapidJSON_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/rapidjson/include")
    find_package(RapidJSON CONFIG REQUIRED)

    # secp256k1
    set(libsecp256k1_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/libsecp256k1/include")
    set(libsecp256k1_LIBRARY_DIR "${THIRDPARTY_BUILD_DIR}/libsecp256k1/lib")
    set(libsecp256k1_DIR "${THIRDPARTY_BUILD_DIR}/libsecp256k1/lib/cmake/libsecp256k1")
    find_package(libsecp256k1 CONFIG REQUIRED)

    # xxhash
    set(xxHash_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/xxHash/include")
    set(xxHash_LIBRARY_DIR "${THIRDPARTY_BUILD_DIR}/xxHash/lib")
    set(xxHash_DIR "${THIRDPARTY_BUILD_DIR}/xxhash/lib/cmake/xxHash")
    find_package(xxHash CONFIG REQUIRED)

    # libssh2
    set(Libssh2_DIR "${THIRDPARTY_BUILD_DIR}/libssh2/lib/cmake/libssh2")
    set(Libssh2_LIBRARY_DIR "${THIRDPARTY_BUILD_DIR}/libssh2/lib")
    set(Libssh2_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/libssh2/include")
    find_package(Libssh2 CONFIG REQUIRED)

    # AsyncIOManager
    set(AsyncIOManager_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/AsyncIOManager/include")
    set(AsyncIOManager_LIBRARY_DIR "${THIRDPARTY_BUILD_DIR}/AsyncIOManager/lib")
    set(AsyncIOManager_DIR "${THIRDPARTY_BUILD_DIR}/AsyncIOManager/lib/cmake/AsyncIOManager")
    find_package(AsyncIOManager CONFIG REQUIRED)

    # gnus_upnp
    set(gnus_upnp_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/gnus_upnp/include")
    set(gnus_upnp_LIBRARY_DIR "${THIRDPARTY_BUILD_DIR}/gnus_upnp/lib")
    set(gnus_upnp_DIR "${THIRDPARTY_BUILD_DIR}/gnus_upnp/lib/cmake/gnus_upnp")
    find_package(gnus_upnp CONFIG REQUIRED)

    # crypto3
    add_library(crypto3::algebra INTERFACE IMPORTED)
    add_library(crypto3::block INTERFACE IMPORTED)
    add_library(crypto3::blueprint INTERFACE IMPORTED)
    add_library(crypto3::codec INTERFACE IMPORTED)
    add_library(crypto3::math INTERFACE IMPORTED)
    add_library(crypto3::multiprecision INTERFACE IMPORTED)
    add_library(crypto3::pkpad INTERFACE IMPORTED)
    add_library(crypto3::pubkey INTERFACE IMPORTED)
    add_library(crypto3::random INTERFACE IMPORTED)
    add_library(crypto3::zk INTERFACE IMPORTED)
    add_library(marshalling::core INTERFACE IMPORTED)
    add_library(marshalling::crypto3_algebra INTERFACE IMPORTED)
    add_library(marshalling::crypto3_multiprecision INTERFACE IMPORTED)
    add_library(marshalling::crypto3_zk INTERFACE IMPORTED)

    set_target_properties(crypto3::algebra PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(crypto3::block PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(crypto3::blueprint PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(crypto3::codec PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(crypto3::math PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(crypto3::multiprecision PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(crypto3::pkpad PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(crypto3::pubkey PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(crypto3::random PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(crypto3::zk PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(marshalling::core PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(marshalling::crypto3_algebra PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(marshalling::crypto3_multiprecision PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    set_target_properties(marshalling::crypto3_zk PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ZKLLVM_BUILD_DIR}/zkLLVM/include"
    )
    # zkLLVM
    set(zkLLVM_INCLUDE_DIR "${ZKLLVM_BUILD_DIR}/zkLLVM/include")

    # llvm
    set(LLVM_DIR "${ZKLLVM_BUILD_DIR}/zkLLVM/lib/cmake/llvm")
    find_package(LLVM CONFIG REQUIRED)


    set(SUPERGENIUS_BUILD_DIR ${SUPERGENIUS_SRC_DIR}${ARCH_OUTPUT_DIR})
    set(SuperGenius_DIR "${SUPERGENIUS_BUILD_DIR}/SuperGenius/lib/cmake/SuperGenius/")
    set(ProofSystem_DIR "${SUPERGENIUS_BUILD_DIR}/SuperGenius/lib/cmake/ProofSystem/")
    message(STATUS "SUPERGENIUS_BUILD_DIR DIR: ${SUPERGENIUS_BUILD_DIR}")
    find_package(ProofSystem CONFIG REQUIRED)
    find_package(SuperGenius CONFIG REQUIRED)

    set(GENIUSSDK_BUILD_DIR ${GENIUSSDK_SRC_DIR}${ARCH_OUTPUT_DIR})
    set(GeniusSDK_DIR "${GENIUSSDK_BUILD_DIR}/GeniusSDK/lib/cmake/GeniusSDK/")
    find_package(GeniusSDK CONFIG REQUIRED)
    set(CMAKE_OSX_DEPLOYMENT_TARGET 12.1)
    set(BUILD_SHARED_LIBS ON)
    
    if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
        add_library(
            GeniusWallet
            SHARED
            ${CMAKE_CURRENT_LIST_DIR}/null.cpp
        )

        if(SET_NAME_UNIX_FORCE)
            set_target_properties(GeniusWallet PROPERTIES SUFFIX ".so")
            set_target_properties(GeniusWallet PROPERTIES PREFIX "lib")
        endif()

        if(CMAKE_SYSTEM_NAME STREQUAL "Android")
            find_library(LOG_LIB log)
            target_link_libraries(GeniusWallet PRIVATE ${LOG_LIB})
        endif()
        if(APPLE)
            target_link_libraries(GeniusWallet PRIVATE
                "-framework CoreFoundation"
                "-framework CoreGraphics"
                "-framework CoreServices"
                "-framework IOKit"
                "-framework IOSurface"
                "-framework Metal"
                "-framework QuartzCore"
                "-framework Foundation"
        )
            if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
                # macOS specific
                target_link_libraries(GeniusWallet PRIVATE
                    "-framework AppKit")
            elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
                # iOS specific
                target_link_libraries(GeniusWallet PRIVATE
                    "-framework UIKit"
                    "-framework Security")
            endif()
        endif()
        #Do this in 2 until osx linking is fixed for multiple.
        TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_W_TYPE(GeniusWallet PRIVATE
            TrustWalletCore
        )
        TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_W_TYPE(GeniusWallet PRIVATE
            sgns::GeniusSDK
        )

        target_link_libraries(GeniusWallet PRIVATE
            wallet_core_rs
            TrezorCrypto
        )
    endif()
endif()
