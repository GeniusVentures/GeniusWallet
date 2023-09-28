#include "TWNervosAddress.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/**
 * @brief       Compares two addresses for equality.
 * @param[in]   lhs The first address to compare.
 * @param[in]   rhs The second address to compare.
 * @return      bool indicating the addresses are equal.
 */
EXPORT_API
bool TWNervosAddressEqualNative(struct TWNervosAddress* _Nonnull lhs,
                                struct TWNervosAddress* _Nonnull rhs)
{
    return TWNervosAddressEqual(lhs, rhs);
}

/// Determines if the string is a valid Nervos address.
///
/// \param string string to validate.
/// \return bool indicating if the address is valid.
EXPORT_API
bool TWNervosAddressIsValidStringNative(TWString* string)
{
    return TWNervosAddressIsValidString(string);
}

/// Initializes an address from a sring representaion.
///
/// \param string Bech32 string to initialize the address from.
/// \return TWNervosAddress pointer or nullptr if string is invalid.
EXPORT_API
struct TWNervosAddress*
TWNervosAddressCreateWithStringNative(TWString* string)
{
    return TWNervosAddressCreateWithString(string);
}

/// Deletes a Nervos address.
///
/// \param address Address to delete.
EXPORT_API
void TWNervosAddressDeleteNative(struct TWNervosAddress* address)
{
    TWNervosAddressDelete(address);
}

/// Returns the address string representation.
///
/// \param address Address to get the string representation of.
EXPORT_API
TWString* TWNervosAddressDescriptionNative(struct TWNervosAddress* address)
{
    return TWNervosAddressDescription(address);
}

/// Returns the Code hash
///
/// \param address Address to get the keyhash data of.
EXPORT_API
TWData* TWNervosAddressCodeHashNative(struct TWNervosAddress* address)
{
    return TWNervosAddressCodeHash(address);
}

/// Returns the address hash type
///
/// \param address Address to get the hash type of.
EXPORT_API
TWString* TWNervosAddressHashTypeNative(struct TWNervosAddress* address)
{
    return TWNervosAddressHashType(address);
}

/// Returns the address args data.
///
/// \param address Address to get the args data of.
EXPORT_API
TWData* TWNervosAddressArgsNative(struct TWNervosAddress* address)
{
    return TWNervosAddressArgs(address);
}
