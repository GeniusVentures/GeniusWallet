#include "TWCointType.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/**
 * @brief       Returns the blockchain for a coin type.
 * @param[in]   coin A coin type
 * @return      blockchain associated to the given coin type
 */
EXPORT_API
enum TWBlockchain TWCoinTypeBlockchainNative(enum TWCoinType coin)
{
    return TWCoinTypeBlockchain(coin);
}

/**
 * @brief       Returns the purpose for a coin type.
 * @param[in]   coin A coin type
 * @return      purpose associated to the given coin type
 */
EXPORT_API
enum TWPurpose TWCoinTypePurposeNative(enum TWCoinType coin)
{
    return TWCoinTypePurpose(coin);
}

/**
 * @brief       Returns the curve that should be used for a coin type.
 * @param[in]   coin A coin type
 * @return      curve that should be used for the given coin type
 */
EXPORT_API
enum TWCurve TWCoinTypeCurveNative(enum TWCoinType coin)
{
    return TWCoinTypeCurve(coin);
}

/**
 * @brief       Returns the xpub HD version that should be used for a coin type.
 * @param[in]   coin A coin type
 * @return      xpub HD version that should be used for the given coin type
 */
EXPORT_API
enum TWHDVersion TWCoinTypeXpubVersionNative(enum TWCoinType coin)
{
    return TWCoinTypeXpubVersion(coin);
}

/**
 * @brief       Returns the xprv HD version that should be used for a coin type.
 * @param[in]   coin A coin type
 * @return      the xprv HD version that should be used for the given coin type.
 */
EXPORT_API
enum TWHDVersion TWCoinTypeXprvVersionNative(enum TWCoinType coin)
{
    return TWCoinTypeXprvVersion(coin);
}

/**
 * @brief       Validates an address string.
 * @param[in]   coin A coin type
 * @param[in]   address A public address
 * @return      true if the address is a valid public address of the given coin, false otherwise.
 */
EXPORT_API
bool TWCoinTypeValidateNative(enum TWCoinType coin, TWString* address)
{
    return TWCoinTypeValidate(coin, address);
}

/**
 * @brief       Returns the default derivation path for a particular coin.
 * @param[in]   coin A coin type
 * @return      the default derivation path for the given coin type.
 */
EXPORT_API
TWString* TWCoinTypeDerivationPathNative(enum TWCoinType coin)
{
    return TWCoinTypeDerivationPath(coin);
}

/**
 * @brief       Returns the derivation path for a particular coin with the explicit given derivation.
 * @param[in]   coin A coin type
 * @param[in]   derivation A derivation type
 * @return      the derivation path for the given coin with the explicit given derivation
 */
EXPORT_API
TWString*
TWCoinTypeDerivationPathWithDerivationNative(enum TWCoinType   coin,
                                             enum TWDerivation derivation)
{
    return TWCoinTypeDerivationPathWithDerivation(coin, derivation);
}

/**
 * @brief       Derives the address for a particular coin from the private key.
 * @param[in]   coin A coin type
 * @param[in]   privateKey A valid private key
 * @return      Derived address for the given coin from the private key.
 */
EXPORT_API
TWString* TWCoinTypeDeriveAddressNative(enum TWCoinType      coin,
                                        struct TWPrivateKey* privateKey)
{
    return TWCoinTypeDeriveAddress(coin, privateKey);
}

/**
 * @brief       Derives the address for a particular coin from the public key.
 * @param[in]   coin A coin type
 * @param[in]   publicKey A valid public key
 * @return      Derived address for the given coin from the public key.
 */
EXPORT_API
TWString*
TWCoinTypeDeriveAddressFromPublicKeyNative(enum TWCoinType     coin,
                                           struct TWPublicKey* publicKey)
{
    return TWCoinTypeDeriveAddressFromPublicKey(coin, publicKey);
}

/**
 * @brief       HRP for this coin type
 * @param[in]   coin A coin type
 * @return      HRP of the given coin type.
 */
EXPORT_API
enum TWHRP TWCoinTypeHRPNative(enum TWCoinType coin)
{
    return TWCoinTypeHRP(coin);
}

/**
 * @brief       P2PKH prefix for this coin type
 * @param[in]   coin A coin type
 * @return      P2PKH prefix for the given coin type
 */
EXPORT_API
uint8_t TWCoinTypeP2pkhPrefixNative(enum TWCoinType coin)
{
    return TWCoinTypeP2pkhPrefix(coin);
}

/**
 * @brief       P2SH prefix for this coin type
 * @param[in]   coin A coin type
 * @return      P2SH prefix for the given coin type
 */
EXPORT_API
uint8_t TWCoinTypeP2shPrefixNative(enum TWCoinType coin)
{
    return TWCoinTypeP2shPrefix(coin);
}

/**
 * @brief       Static prefix for this coin type
 * @param[in]   coin A coin type
 * @return      Static prefix for the given coin type
 */
EXPORT_API
uint8_t TWCoinTypeStaticPrefixNative(enum TWCoinType coin)
{
    return TWCoinTypeStaticPrefix(coin);
}

/**
 * @brief       ChainID for this coin type.
 * @param[in]   coin A coin type
 * @return      ChainID for the given coin type.
 * @note        Caller must free returned object.
 */
EXPORT_API
TWString* TWCoinTypeChainIdNative(enum TWCoinType coin)
{
    return TWCoinTypeChainId(coin);
}

/**
 * @brief       SLIP-0044 id for this coin type
 * @param[in]   coin A coin type
 * @return      SLIP-0044 id for the given coin type
 */
EXPORT_API
uint32_t TWCoinTypeSlip44IdNative(enum TWCoinType coin)
{
    return TWCoinTypeSlip44Id(coin);
}

/**
 * @brief       SS58Prefix for this coin type
 * @param[in]   coin A coin type
 * @return      SS58Prefix for the given coin type
 */
EXPORT_API
uint32_t TWCoinTypeSS58PrefixNative(enum TWCoinType coin)
{
    return TWCoinTypeSS58Prefix(coin);
}

/**
 * @brief       public key type for this coin type
 * @param[in]   coin A coin type
 * @return      public key type for the given coin type
 */
EXPORT_API
enum TWPublicKeyType TWCoinTypePublicKeyTypeNative(enum TWCoinType coin)
{
    return TWCoinTypePublicKeyType(coin);
}