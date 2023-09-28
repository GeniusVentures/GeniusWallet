#include "TWHDWallet.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Creates a new HDWallet with a new random mnemonic with the provided strength in bits.
///
/// \param strength strength in bits
/// \param passphrase non-null passphrase
/// \note Null is returned on invalid strength
/// \note Returned object needs to be deleted with \TWHDWalletDelete
/// \return Nullable TWHDWallet
EXPORT_API
struct TWHDWallet* TWHDWalletCreateNative(int strength, TWString* passphrase)
{
    return TWHDWalletCreate(strength, passphrase);
}

/// Creates an HDWallet from a valid BIP39 English mnemonic and a passphrase.
///
/// \param mnemonic non-null Valid BIP39 mnemonic
/// \param passphrase  non-null passphrase
/// \note Null is returned on invalid mnemonic
/// \note Returned object needs to be deleted with \TWHDWalletDelete
/// \return Nullable TWHDWallet
EXPORT_API
struct TWHDWallet* TWHDWalletCreateWithMnemonicNative(TWString* mnemonic,
                                                      TWString* passphrase)
{
    return TWHDWalletCreateWithMnemonic(mnemonic, passphrase);
}

/// Creates an HDWallet from a BIP39 mnemonic, a passphrase and validation flag.
///
/// \param mnemonic non-null Valid BIP39 mnemonic
/// \param passphrase  non-null passphrase
/// \param check validation flag
/// \note Null is returned on invalid mnemonic
/// \note Returned object needs to be deleted with \TWHDWalletDelete
/// \return Nullable TWHDWallet
EXPORT_API
struct TWHDWallet*
TWHDWalletCreateWithMnemonicCheckNative(TWString* mnemonic,
                                        TWString* passphrase, bool check)
{
    return TWHDWalletCreateWithMnemonicCheck(mnemonic, passphrase, check);
}

/// Creates an HDWallet from entropy (corresponding to a mnemonic).
///
/// \param entropy Non-null entropy data (corresponding to a mnemonic)
/// \param passphrase non-null passphrase
/// \note Null is returned on invalid input
/// \note Returned object needs to be deleted with \TWHDWalletDelete
/// \return Nullable TWHDWallet
EXPORT_API
struct TWHDWallet* TWHDWalletCreateWithEntropyNative(TWData*   entropy,
                                                     TWString* passphrase)
{
    return TWHDWalletCreateWithEntropy(entropy, passphrase);
}

/// Deletes a wallet.
///
/// \param wallet non-null TWHDWallet
EXPORT_API
void TWHDWalletDeleteNative(struct TWHDWallet* wallet)
{
    TWHDWalletDelete(wallet);
}

/// Wallet seed.
///
/// \param wallet non-null TWHDWallet
/// \return The wallet seed as a Non-null block of data.
EXPORT_API
TWData* TWHDWalletSeedNative(struct TWHDWallet* wallet)
{
    return TWHDWalletSeed(wallet);
}

/// Wallet Mnemonic
///
/// \param wallet non-null TWHDWallet
/// \return The wallet mnemonic as a non-null TWString
EXPORT_API
TWString* TWHDWalletMnemonicNative(struct TWHDWallet* wallet)
{
    return TWHDWalletMnemonic(wallet);
}

/// Wallet entropy
///
/// \param wallet non-null TWHDWallet
/// \return The wallet entropy as a non-null block of data.
EXPORT_API
TWData* TWHDWalletEntropyNative(struct TWHDWallet* wallet)
{
    return TWHDWalletEntropy(wallet);
}

/// Returns master key.
///
/// \param wallet non-null TWHDWallet
/// \param curve  a curve
/// \note Returned object needs to be deleted with \TWPrivateKeyDelete
/// \return Non-null corresponding private key
EXPORT_API
struct TWPrivateKey* TWHDWalletGetMasterKeyNative(struct TWHDWallet* wallet,
                                                  enum TWCurve       curve)
{
    return TWHDWalletGetMasterKey(wallet, curve);
}

/// Generates the default private key for the specified coin, using default derivation.
///
/// \see TWHDWalletGetKey
/// \see TWHDWalletGetKeyDerivation
/// \param wallet non-null TWHDWallet
/// \param coin  a coin type
/// \note Returned object needs to be deleted with \TWPrivateKeyDelete
/// \return return the default private key for the specified coin
EXPORT_API
struct TWPrivateKey* TWHDWalletGetKeyForCoinNative(struct TWHDWallet* wallet,
                                                   enum TWCoinType    coin)
{
    return TWHDWalletGetKeyForCoin(wallet, coin);
}

/// Generates the default address for the specified coin (without exposing intermediary private key), default derivation.
///
/// \see TWHDWalletGetAddressDerivation
/// \param wallet non-null TWHDWallet
/// \param coin  a coin type
/// \return return the default address for the specified coin as a non-null TWString
EXPORT_API
TWString* TWHDWalletGetAddressForCoinNative(struct TWHDWallet* wallet,
                                            enum TWCoinType    coin)
{
    return TWHDWalletGetAddressForCoin(wallet, coin);
}

/// Generates the default address for the specified coin and derivation (without exposing intermediary private key).
///
/// \see TWHDWalletGetAddressForCoin
/// \param wallet non-null TWHDWallet
/// \param coin  a coin type
/// \param derivation  a (custom) derivation to use
/// \return return the default address for the specified coin as a non-null TWString
EXPORT_API
TWString* TWHDWalletGetAddressDerivationNative(struct TWHDWallet* wallet,
                                               enum TWCoinType    coin,
                                               enum TWDerivation  derivation)
{
    return TWHDWalletGetAddressDerivation(wallet, coin, derivation);
}

/// Generates the private key for the specified derivation path.
///
/// \see TWHDWalletGetKeyForCoin
/// \see TWHDWalletGetKeyDerivation
/// \param wallet non-null TWHDWallet
/// \param coin a coin type
/// \param derivationPath  a non-null derivation path
/// \note Returned object needs to be deleted with \TWPrivateKeyDelete
/// \return The private key for the specified derivation path/coin
EXPORT_API
struct TWPrivateKey* TWHDWalletGetKeyNative(struct TWHDWallet* wallet,
                                            enum TWCoinType    coin,
                                            TWString*          derivationPath)
{
    return TWHDWalletGetKey(wallet, coin, derivationPath);
}

/// Generates the private key for the specified derivation.
///
/// \see TWHDWalletGetKey
/// \see TWHDWalletGetKeyForCoin
/// \param wallet non-null TWHDWallet
/// \param coin a coin type
/// \param derivation a (custom) derivation to use
/// \note Returned object needs to be deleted with \TWPrivateKeyDelete
/// \return The private key for the specified derivation path/coin
EXPORT_API
struct TWPrivateKey*
TWHDWalletGetKeyDerivationNative(struct TWHDWallet* wallet,
                                 enum TWCoinType    coin,
                                 enum TWDerivation  derivation)
{
    return TWHDWalletGetKeyDerivation(wallet, coin, derivation);
}

/// Generates the private key for the specified derivation path and curve.
///
/// \param wallet non-null TWHDWallet
/// \param curve a curve
/// \param derivationPath  a non-null derivation path
/// \note Returned object needs to be deleted with \TWPrivateKeyDelete
/// \return The private key for the specified derivation path/curve
EXPORT_API
struct TWPrivateKey* TWHDWalletGetKeyByCurveNative(struct TWHDWallet* wallet,
                                                   enum TWCurve       curve,
                                                   TWString* derivationPath)
{
    return TWHDWalletGetKeyByCurve(wallet, curve, derivationPath);
}

/// Shortcut method to generate private key with the specified account/change/address (bip44 standard).
///
/// \see https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
///
/// \param wallet non-null TWHDWallet
/// \param coin a coin type
/// \param account valid bip44 account
/// \param change valid bip44 change
/// \param address valid bip44 address
/// \note Returned object needs to be deleted with \TWPrivateKeyDelete
/// \return The private key for the specified bip44 parameters
EXPORT_API
struct TWPrivateKey* TWHDWalletGetDerivedKeyNative(struct TWHDWallet* wallet,
                                                   enum TWCoinType    coin,
                                                   uint32_t           account,
                                                   uint32_t           change,
                                                   uint32_t           address)
{
    return TWHDWalletGetDerivedKey(wallet, coin, account, change, address);
}

/// Returns the extended private key (for default 0 account).
///
/// \param wallet non-null TWHDWallet
/// \param purpose a purpose
/// \param coin a coin type
/// \param version hd version
/// \note Returned object needs to be deleted with \TWStringDelete
/// \return  Extended private key as a non-null TWString
EXPORT_API
TWString* TWHDWalletGetExtendedPrivateKeyNative(struct TWHDWallet* wallet,
                                                enum TWPurpose     purpose,
                                                enum TWCoinType    coin,
                                                enum TWHDVersion   version)
{
    return TWHDWalletGetExtendedPrivateKey(wallet, purpose, coin, version);
}

/// Returns the extended public key (for default 0 account).
///
/// \param wallet non-null TWHDWallet
/// \param purpose a purpose
/// \param coin a coin type
/// \param version hd version
/// \note Returned object needs to be deleted with \TWStringDelete
/// \return  Extended public key as a non-null TWString
EXPORT_API
TWString* TWHDWalletGetExtendedPublicKeyNative(struct TWHDWallet* wallet,
                                               enum TWPurpose     purpose,
                                               enum TWCoinType    coin,
                                               enum TWHDVersion   version)
{
    return TWHDWalletGetExtendedPublicKey(wallet, purpose, coin, version);
}

/// Returns the extended private key, for custom account.
///
/// \param wallet non-null TWHDWallet
/// \param purpose a purpose
/// \param coin a coin type
/// \param derivation a derivation
/// \param version an hd version
/// \param account valid bip44 account
/// \note Returned object needs to be deleted with \TWStringDelete
/// \return  Extended private key as a non-null TWString
EXPORT_API
TWString* TWHDWalletGetExtendedPrivateKeyAccountNative(
    struct TWHDWallet* wallet, enum TWPurpose purpose, enum TWCoinType coin,
    enum TWDerivation derivation, enum TWHDVersion version, uint32_t account)
{
    return TWHDWalletGetExtendedPrivateKeyAccount(
        wallet, purpose, coin, derivation, version, account);
}

/// Returns the extended public key, for custom account.
///
/// \param wallet non-null TWHDWallet
/// \param purpose a purpose
/// \param coin a coin type
/// \param derivation a derivation
/// \param version an hd version
/// \param account valid bip44 account
/// \note Returned object needs to be deleted with \TWStringDelete
/// \return Extended public key as a non-null TWString
EXPORT_API
TWString* TWHDWalletGetExtendedPublicKeyAccountNative(
    struct TWHDWallet* wallet, enum TWPurpose purpose, enum TWCoinType coin,
    enum TWDerivation derivation, enum TWHDVersion version, uint32_t account)
{
    return TWHDWalletGetExtendedPublicKeyAccount(
        wallet, purpose, coin, derivation, version, account);
}

/// Returns the extended private key (for default 0 account with derivation).
///
/// \param wallet non-null TWHDWallet
/// \param purpose a purpose
/// \param coin a coin type
/// \param derivation a derivation
/// \param version an hd version
/// \note Returned object needs to be deleted with \TWStringDelete
/// \return  Extended private key as a non-null TWString
EXPORT_API
TWString* TWHDWalletGetExtendedPrivateKeyDerivationNative(
    struct TWHDWallet* wallet, enum TWPurpose purpose, enum TWCoinType coin,
    enum TWDerivation derivation, enum TWHDVersion version)
{
    return TWHDWalletGetExtendedPrivateKeyDerivation(wallet, purpose, coin,
                                                     derivation, version);
}

/// Returns the extended public key (for default 0 account with derivation).
///
/// \param wallet non-null TWHDWallet
/// \param purpose a purpose
/// \param coin a coin type
/// \param derivation a derivation
/// \param version an hd version
/// \note Returned object needs to be deleted with \TWStringDelete
/// \return  Extended public key as a non-null TWString
EXPORT_API
TWString* TWHDWalletGetExtendedPublicKeyDerivationNative(
    struct TWHDWallet* wallet, enum TWPurpose purpose, enum TWCoinType coin,
    enum TWDerivation derivation, enum TWHDVersion version)
{
    return TWHDWalletGetExtendedPublicKeyDerivation(wallet, purpose, coin,
                                                    derivation, version);
}

/// Computes the public key from an extended public key representation.
///
/// \param extended extended public key
/// \param coin a coin type
/// \param derivationPath a derivation path
/// \note Returned object needs to be deleted with \TWPublicKeyDelete
/// \return Nullable TWPublic key
EXPORT_API
struct TWPublicKey* TWHDWalletGetPublicKeyFromExtendedNative(
    TWString* extended, enum TWCoinType coin, TWString* derivationPath)
{
    return TWHDWalletGetPublicKeyFromExtended(extended, coin, derivationPath);
}
