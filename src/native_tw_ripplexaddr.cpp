#include "TWRippleXAddress.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Compares two addresses for equality.
///
/// \param lhs left non-null pointer to a Ripple Address
/// \param rhs right non-null pointer to a Ripple Address
/// \return true if both address are equal, false otherwise
EXPORT_API
bool TWRippleXAddressEqualNative(struct TWRippleXAddress* lhs,
                                 struct TWRippleXAddress* rhs)
{
    return TWRippleXAddressEqual(lhs, rhs);
}

/// Determines if the string is a valid Ripple address.
///
/// \param string Non-null pointer to a string that represent the Ripple Address to be checked
/// \return true if the given address is a valid Ripple address, false otherwise
EXPORT_API
bool TWRippleXAddressIsValidStringNative(TWString* string)
{
    return TWRippleXAddressIsValidString(string);
}

/// Creates an address from a string representation.
///
/// \param string Non-null pointer to a string that should be a valid ripple address
/// \note Should be deleted with \TWRippleXAddressDelete
/// \return Null pointer if the given string is an invalid ripple address, pointer to a Ripple address otherwise
EXPORT_API
struct TWRippleXAddress*
TWRippleXAddressCreateWithStringNative(TWString* string)
{
    return TWRippleXAddressCreateWithString(string);
}

/// Creates an address from a public key and destination tag.
///
/// \param publicKey Non-null pointer to a public key
/// \param tag valid ripple destination tag (1-10)
/// \note Should be deleted with \TWRippleXAddressDelete
/// \return Non-null pointer to a Ripple Address
EXPORT_API
struct TWRippleXAddress*
TWRippleXAddressCreateWithPublicKeyNative(struct TWPublicKey* publicKey,
                                          uint32_t            tag)
{
    return TWRippleXAddressCreateWithPublicKey(publicKey, tag);
};

/// Delete the given ripple address
///
/// \param address Non-null pointer to a Ripple Address
EXPORT_API
void TWRippleXAddressDeleteNative(struct TWRippleXAddress* address)
{
     TWRippleXAddressDelete(address);
}

/// Returns the address string representation.
///
/// \param address Non-null pointer to a Ripple Address
/// \return Non-null pointer to the ripple address string representation
EXPORT_API
TWString* TWRippleXAddressDescriptionNative(struct TWRippleXAddress* address)
{
    return TWRippleXAddressDescription(address);
}

/// Returns the destination tag.
///
/// \param address Non-null pointer to a Ripple Address
/// \return The destination tag of the given Ripple Address (1-10)
EXPORT_API
uint32_t TWRippleXAddressTagNative(struct TWRippleXAddress* address)
{
    return TWRippleXAddressTag(address);
}