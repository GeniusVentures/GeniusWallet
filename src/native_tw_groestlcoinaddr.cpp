#include "TWGroestlcoinAddress.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Compares two addresses for equality.
///
/// \param lhs left Non-null GroestlCoin address to be compared
/// \param rhs right Non-null GroestlCoin address to be compared
/// \return true if both address are equal, false otherwise
EXPORT_API
bool TWGroestlcoinAddressEqualNative(struct TWGroestlcoinAddress* lhs,
                                     struct TWGroestlcoinAddress* rhs)
{
    return TWGroestlcoinAddressEqual(lhs, rhs);
};

/// Determines if the string is a valid Groestlcoin address.
///
/// \param string Non-null string.
/// \return true if it's a valid address, false otherwise
EXPORT_API
bool TWGroestlcoinAddressIsValidStringNative(TWString* string)
{
    return TWGroestlcoinAddressIsValidString(string);
};

/// Create an address from a base58 string representation.
///
/// \param string Non-null string
/// \note Must be deleted with \TWGroestlcoinAddressDelete
/// \return Non-null GroestlcoinAddress
EXPORT_API
struct TWGroestlcoinAddress*
TWGroestlcoinAddressCreateWithStringNative(TWString* string)
{
    return TWGroestlcoinAddressCreateWithString(string);
};

/// Create an address from a public key and a prefix byte.
///
/// \param publicKey Non-null public key
/// \param prefix public key prefix
/// \note Must be deleted with \TWGroestlcoinAddressDelete
/// \return Non-null GroestlcoinAddress
EXPORT_API
struct TWGroestlcoinAddress*
TWGroestlcoinAddressCreateWithPublicKeyNative(struct TWPublicKey* publicKey,
                                              uint8_t             prefix)
{
    return TWGroestlcoinAddressCreateWithPublicKey(publicKey, prefix);
};

/// Delete a Groestlcoin address
///
/// \param address Non-null GroestlcoinAddress
EXPORT_API
void TWGroestlcoinAddressDeleteNative(struct TWGroestlcoinAddress* address)
{
    TWGroestlcoinAddressDelete(address);
};

/// Returns the address base58 string representation.
///
/// \param address Non-null GroestlcoinAddress
/// \return Address description as a non-null string
EXPORT_API
TWString*
TWGroestlcoinAddressDescriptionNative(struct TWGroestlcoinAddress* address)
{
    return TWGroestlcoinAddressDescription(address);
};
