#include "TWBitcoinAddress.h"

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
bool TWBitcoinAddressEqualNative(struct TWBitcoinAddress* _Nonnull lhs,
                                 struct TWBitcoinAddress* _Nonnull rhs)
{
    return TWBitcoinAddressEqual(lhs, rhs);
};

/// Determines if the data is a valid Bitcoin address.
///
/// \param data data to validate.
/// \return bool indicating if the address data is valid.
EXPORT_API
bool TWBitcoinAddressIsValidNative(TWData* _Nonnull data)
{
    return TWBitcoinAddressIsValid(data);
};

/// Determines if the string is a valid Bitcoin address.
///
/// \param string string to validate.
/// \return bool indicating if the address string is valid.
EXPORT_API
bool TWBitcoinAddressIsValidStringNative(TWString* _Nonnull string)
{
    return TWBitcoinAddressIsValidString(string);
};

/// Initializes an address from a Base58 sring. Must be deleted with TWBitcoinAddressDelete after use.
///
/// \param string Base58 string to initialize the address from.
/// \return TWBitcoinAddress pointer or nullptr if string is invalid.
EXPORT_API
struct TWBitcoinAddress*
TWBitcoinAddressCreateWithStringNative(TWString* string)
{
    return TWBitcoinAddressCreateWithString(string);
};

/// Initializes an address from raw data.
///
/// \param data Raw data to initialize the address from. Must be deleted with TWBitcoinAddressDelete after use.
/// \return TWBitcoinAddress pointer or nullptr if data is invalid.
EXPORT_API
struct TWBitcoinAddress* TWBitcoinAddressCreateWithDataNative(TWData* data)
{
    return TWBitcoinAddressCreateWithData(data);
};

/// Initializes an address from a public key and a prefix byte.
///
/// \param publicKey Public key to initialize the address from.
/// \param prefix Prefix byte (p2pkh, p2sh, etc).
/// \return TWBitcoinAddress pointer or nullptr if public key is invalid.
EXPORT_API
struct TWBitcoinAddress*
TWBitcoinAddressCreateWithPublicKeyNative(struct TWPublicKey* publicKey,
                                          uint8_t             prefix)
{
    return TWBitcoinAddressCreateWithPublicKey(publicKey, prefix);
};

/// Deletes a legacy Bitcoin address.
///
/// \param address Address to delete.
EXPORT_API
void TWBitcoinAddressDeleteNative(struct TWBitcoinAddress* address)
{
    return TWBitcoinAddressDelete(address);
};

/// Returns the address in Base58 string representation.
///
/// \param address Address to get the string representation of.
EXPORT_API
TWString* TWBitcoinAddressDescriptionNative(struct TWBitcoinAddress* address)
{
    return TWBitcoinAddressDescription(address);
};

/// Returns the address prefix.
///
/// \param address Address to get the prefix of.
EXPORT_API
uint8_t TWBitcoinAddressPrefixNative(struct TWBitcoinAddress* address)
{
    return TWBitcoinAddressPrefix(address);
};

/// Returns the key hash data.
///
/// \param address Address to get the keyhash data of.
EXPORT_API
TWData* TWBitcoinAddressKeyhashNative(struct TWBitcoinAddress* address)
{
    return TWBitcoinAddressKeyhash(address);
};
