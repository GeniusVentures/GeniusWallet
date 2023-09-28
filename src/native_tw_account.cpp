#include "TWAccount.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Creates a new Account with an address, a coin type, derivation enum, derivationPath, publicKey,
/// and extendedPublicKey. Must be deleted with TWAccountDelete after use.
///
/// \param address The address of the Account.
/// \param coin The coin type of the Account.
/// \param derivation The derivation of the Account.
/// \param derivationPath The derivation path of the Account.
/// \param publicKey hex encoded public key.
/// \param extendedPublicKey Base58 encoded extended public key.
/// \return A new Account.
EXPORT_API
struct TWAccount*
TWAccountCreateNative(TWString* address, enum TWCoinType coin,
                      enum TWDerivation derivation, TWString* derivationPath,
                      TWString* publicKey, TWString* extendedPublicKey)
{
    return TWAccountCreate(address, coin, derivation, derivationPath,
                           publicKey, extendedPublicKey);
}

/// Deletes an account.
///
/// \param account Account to delete.
EXPORT_API
void TWAccountDeleteNative(struct TWAccount* account)
{
    TWAccountDelete(account);
}

/// Returns the address of an account.
///
/// \param account Account to get the address of.
EXPORT_API
TWString* TWAccountAddressNative(struct TWAccount* account)
{
    return TWAccountAddress(account);
}

/// Return CoinType enum of an account.
///
/// \param account Account to get the coin type of.
EXPORT_API
enum TWCoinType TWAccountCoinNative(struct TWAccount* account)
{
    return TWAccountCoin(account);
}

/// Returns the derivation enum of an account.
///
/// \param account Account to get the derivation enum of.
EXPORT_API
enum TWDerivation TWAccountDerivationNative(struct TWAccount* account)
{
    return TWAccountDerivation(account);
}

/// Returns derivationPath of an account.
///
/// \param account Account to get the derivation path of.
EXPORT_API
TWString* TWAccountDerivationPathNative(struct TWAccount* account)
{
    return TWAccountDerivationPath(account);
}

/// Returns hex encoded publicKey of an account.
///
/// \param account Account to get the public key of.
EXPORT_API
TWString* TWAccountPublicKeyNative(struct TWAccount* account)
{
    return TWAccountPublicKey(account);
}

/// Returns Base58 encoded extendedPublicKey of an account.
///
/// \param account Account to get the extended public key of.
EXPORT_API
TWString* TWAccountExtendedPublicKeyNative(struct TWAccount* account)
{
    return TWAccountExtendedPublicKey(account);
}
