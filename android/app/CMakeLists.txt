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
add_library(wallet_core_trezor STATIC IMPORTED)
set_target_properties(wallet_core_trezor PROPERTIES 
    IMPORTED_LOCATION ${WALLET_CORE_LIB_DIR}/${ANDROID_ABI}/wallet-core/lib/libTrezorCrypto.a
)

add_library( 
    GeniusWallet
    SHARED
    ${PRJ_WRAPPER_DIR}/native_tw_data.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_string.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_filecoin.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_hdversion.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_hrp.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_nervosaddress.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_datavector.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_transactioncompiler.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_anysigner.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_publickey.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_privatekey.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_tronmessage.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_nearaccount.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_bitcoinaddress.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_ethereumabi.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_groestlcoinaddr.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_segwitaddress.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_derivationpath.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_hdwallet.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_storedkey.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_ripplexaddr.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_base64.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_mnemonic.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_bitcoinsighash.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_bitcoinscript.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_ethmsgsigner.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_btcmsgsigner.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_hash.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_ethereumabivalue.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_thorchainswap.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_ethereum.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_stellarpassphrase.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_derivationpathidx.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_cardano.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_cointypecfg.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_ethabifunction.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_pbkdf2.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_solanaaddress.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_base32.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_starkexmsgsigner.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_tezosmsgsigner.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_aes.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_fioaccount.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_base58.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_account.cpp
    #${PRJ_WRAPPER_DIR}/native_tw_starkware.cpp
)
target_link_libraries( GeniusWallet
    walletcore
    wallet_core_trezor
    wallet_core_rust
)