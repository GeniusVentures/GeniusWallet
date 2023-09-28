#include "TWSegwitAddress.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Compares two addresses for equality.
///
/// \param lhs left non-null pointer to a Bech32 Address
/// \param rhs right non-null pointer to a Bech32 Address
/// \return true if both address are equal, false otherwise
EXPORT_API
bool TWSegwitAddressEqualNative(struct TWSegwitAddress* lhs,
                                struct TWSegwitAddress* rhs)
{
    return TWSegwitAddressEqual(lhs, rhs);
};

/// Determines if the string is a valid Bech32 address.
///
/// \param string Non-null pointer to a Bech32 address as a string
/// \return true if the string is a valid Bech32 address, false otherwise.
EXPORT_API
bool TWSegwitAddressIsValidStringNative(TWString* string)
{
    return TWSegwitAddressIsValidString(string);
};

/// Creates an address from a string representation.
///
/// \param string Non-null pointer to a Bech32 address as a string
/// \note should be deleted with \TWSegwitAddressDelete
/// \return Pointer to a Bech32 address if the string is a valid Bech32 address, null pointer otherwise
EXPORT_API
struct TWSegwitAddress*
TWSegwitAddressCreateWithStringNative(TWString* string)
{
    return TWSegwitAddressCreateWithString(string);
};

/// Creates a segwit-version-0 address from a public key and HRP prefix.
/// Taproot (v>=1) is not supported by this method.
///
/// \param hrp HRP of the utxo coin targeted
/// \param publicKey Non-null pointer to the public key of the targeted coin
/// \note should be deleted with \TWSegwitAddressDelete
/// \return Non-null pointer to the corresponding Segwit address
EXPORT_API
struct TWSegwitAddress*
TWSegwitAddressCreateWithPublicKeyNative(enum TWHRP          hrp,
                                         struct TWPublicKey* publicKey)
{
    return TWSegwitAddressCreateWithPublicKey(hrp, publicKey);
};

/// Delete the given Segwit address
///
/// \param address Non-null pointer to a Segwit address
EXPORT_API
void TWSegwitAddressDeleteNative(struct TWSegwitAddress* address)
{
    TWSegwitAddressDelete(address);
};

/// Returns the address string representation.
///
/// \param address Non-null pointer to a Segwit Address
/// \return Non-null pointer to the segwit address string representation
EXPORT_API
TWString* TWSegwitAddressDescriptionNative(struct TWSegwitAddress* address)
{
    return TWSegwitAddressDescription(address);
};

/// Returns the human-readable part.
///
/// \param address Non-null pointer to a Segwit Address
/// \return the HRP part of the given address
EXPORT_API
enum TWHRP TWSegwitAddressHRPNative(struct TWSegwitAddress* address)
{
    return TWSegwitAddressHRP(address);
};

/// Returns the human-readable part.
///
/// \param address Non-null pointer to a Segwit Address
/// \return returns the witness version of the given segwit address
EXPORT_API
int TWSegwitAddressWitnessVersionNative(struct TWSegwitAddress* address)
{
    return TWSegwitAddressWitnessVersion(address);
};

/// Returns the witness program
///
/// \param address Non-null pointer to a Segwit Address
/// \return returns the witness data of the given segwit address as a non-null pointer block of data
EXPORT_API
TWData* TWSegwitAddressWitnessProgramNative(struct TWSegwitAddress* address)
{
    return TWSegwitAddressWitnessProgram(address);
};
