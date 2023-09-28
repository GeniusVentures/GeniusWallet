#include "TWAnyAddress.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Compares two addresses for equality.
///
/// \param lhs The first address to compare.
/// \param rhs The second address to compare.
/// \return bool indicating the addresses are equal.
EXPORT_API
bool TWAnyAddressEqualNative(struct TWAnyAddress* lhs,
                             struct TWAnyAddress* rhs)
{
    return TWAnyAddressEqual(lhs, rhs);
};

/// Determines if the string is a valid Any address.
///
/// \param string address to validate.
/// \param coin coin type of the address.
/// \return bool indicating if the address is valid.
EXPORT_API
bool TWAnyAddressIsValidNative(TWString* string, enum TWCoinType coin)
{
    return TWAnyAddressIsValid(string, coin);
};

/// Determines if the string is a valid Any address with the given hrp.
///
/// \param string address to validate.
/// \param coin coin type of the address.
/// \param hrp explicit given hrp of the given address.
/// \return bool indicating if the address is valid.
EXPORT_API
bool TWAnyAddressIsValidBech32Native(TWString* string, enum TWCoinType coin,
                                     TWString* hrp)
{
    return TWAnyAddressIsValidBech32(string, coin, hrp);
};

/// Determines if the string is a valid Any address with the given SS58 network prefix.
///
/// \param string address to validate.
/// \param coin coin type of the address.
/// \param ss58Prefix ss58Prefix of the given address.
/// \return bool indicating if the address is valid.
EXPORT_API
bool TWAnyAddressIsValidSS58Native(TWString* string, enum TWCoinType coin,
                                   uint32_t ss58Prefix)
{
    return TWAnyAddressIsValidSS58(string, coin, ss58Prefix);
};

/// Creates an address from a string representation and a coin type. Must be deleted with TWAnyAddressDelete after use.
///
/// \param string address to create.
/// \param coin coin type of the address.
/// \return TWAnyAddress pointer or nullptr if address and coin are invalid.
EXPORT_API
struct TWAnyAddress* TWAnyAddressCreateWithStringNative(TWString* string,
                                                        enum TWCoinType coin)
{
    return TWAnyAddressCreateWithString(string, coin);
};

/// Creates an bech32 address from a string representation, a coin type and the given hrp. Must be deleted with TWAnyAddressDelete after use.
///
/// \param string address to create.
/// \param coin coin type of the address.
/// \param hrp hrp of the address.
/// \return TWAnyAddress pointer or nullptr if address and coin are invalid.
EXPORT_API
struct TWAnyAddress* TWAnyAddressCreateBech32Native(TWString*       string,
                                                    enum TWCoinType coin,
                                                    TWString*       hrp)
{
    return TWAnyAddressCreateBech32(string, coin, hrp);
};

/// Creates an SS58 address from a string representation, a coin type and the given ss58Prefix. Must be deleted with TWAnyAddressDelete after use.
///
/// \param string address to create.
/// \param coin coin type of the address.
/// \param ss58Prefix ss58Prefix of the SS58 address.
/// \return TWAnyAddress pointer or nullptr if address and coin are invalid.
EXPORT_API
struct TWAnyAddress* TWAnyAddressCreateSS58Native(TWString*       string,
                                                  enum TWCoinType coin,
                                                  uint32_t        ss58Prefix)
{
    return TWAnyAddressCreateSS58(string, coin, ss58Prefix);
};

/// Creates an address from a public key.
///
/// \param publicKey derivates the address from the public key.
/// \param coin coin type of the address.
/// \return TWAnyAddress pointer or nullptr if public key is invalid.
EXPORT_API
struct TWAnyAddress*
TWAnyAddressCreateWithPublicKeyNative(struct TWPublicKey* publicKey,
                                      enum TWCoinType     coin)
{
    return TWAnyAddressCreateWithPublicKey(publicKey, coin);
};

/// Creates an address from a public key and derivation option.
///
/// \param publicKey derivates the address from the public key.
/// \param coin coin type of the address.
/// \param derivation the custom derivation to use.
/// \return TWAnyAddress pointer or nullptr if public key is invalid.
EXPORT_API
struct TWAnyAddress*
TWAnyAddressCreateWithPublicKeyDerivationNative(struct TWPublicKey* publicKey,
                                                enum TWCoinType     coin,
                                                enum TWDerivation derivation)
{
    return TWAnyAddressCreateWithPublicKeyDerivation(publicKey, coin,
                                                     derivation);
};

/// Creates an bech32 address from a public key and a given hrp.
///
/// \param publicKey derivates the address from the public key.
/// \param coin coin type of the address.
/// \param hrp hrp of the address.
/// \return TWAnyAddress pointer or nullptr if public key is invalid.
EXPORT_API
struct TWAnyAddress* TWAnyAddressCreateBech32WithPublicKeyNative(
    struct TWPublicKey* publicKey, enum TWCoinType coin, TWString* hrp)
{
    return TWAnyAddressCreateBech32WithPublicKey(publicKey, coin, hrp);
};

/// Creates an SS58 address from a public key and a given ss58Prefix.
///
/// \param publicKey derivates the address from the public key.
/// \param coin coin type of the address.
/// \param ss58Prefix ss58Prefix of the SS58 address.
/// \return TWAnyAddress pointer or nullptr if public key is invalid.
EXPORT_API
struct TWAnyAddress* TWAnyAddressCreateSS58WithPublicKeyNative(
    struct TWPublicKey* publicKey, enum TWCoinType coin, uint32_t ss58Prefix)
{
    return TWAnyAddressCreateSS58WithPublicKey(publicKey, coin, ss58Prefix);
};

/// Creates a Filecoin address from a public key and a given address type.
///
/// \param publicKey derivates the address from the public key.
/// \param filecoinAddressType Filecoin address type.
/// \return TWAnyAddress pointer or nullptr if public key is invalid.
EXPORT_API
struct TWAnyAddress* TWAnyAddressCreateWithPublicKeyFilecoinAddressTypeNative(
    struct TWPublicKey*        publicKey,
    enum TWFilecoinAddressType filecoinAddressType)
{
    return TWAnyAddressCreateWithPublicKeyFilecoinAddressType(
        publicKey, filecoinAddressType);
};

/// Deletes an address.
///
/// \param address address to delete.
EXPORT_API
void TWAnyAddressDeleteNative(struct TWAnyAddress* address)
{
    TWAnyAddressDelete(address);
};

/// Returns the address string representation.
///
/// \param address address to get the string representation of.
EXPORT_API
TWString* TWAnyAddressDescriptionNative(struct TWAnyAddress* address)
{
    return TWAnyAddressDescription(address);
};

/// Returns coin type of address.
///
/// \param address address to get the coin type of.
EXPORT_API
enum TWCoinType TWAnyAddressCoinNative(struct TWAnyAddress* address)
{
    return TWAnyAddressCoin(address);
};

/// Returns underlaying data (public key or key hash)
///
/// \param address address to get the data of.
EXPORT_API
TWData* TWAnyAddressDataNative(struct TWAnyAddress* address)
{
    return TWAnyAddressData(address);
};