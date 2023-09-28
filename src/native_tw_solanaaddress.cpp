#include "TWSolanaAddress.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Creates an address from a string representation.
///
/// \param string Non-null pointer to a solana address string
/// \note Should be deleted with \TWSolanaAddressDelete
/// \return Non-null pointer to a Solana address data structure
EXPORT_API
struct TWSolanaAddress*
TWSolanaAddressCreateWithStringNative(TWString* string)
{
    return TWSolanaAddressCreateWithString(string);
}

/// Delete the given Solana address
///
/// \param address Non-null pointer to a Solana Address
EXPORT_API
void TWSolanaAddressDeleteNative(struct TWSolanaAddress* address)
{
    TWSolanaAddressDelete(address);
}

/// Derive default token address for token
///
/// \param address Non-null pointer to a Solana Address
/// \param tokenMintAddress Non-null pointer to a token mint address as a string
/// \return Null pointer if the Default token address for a token is not found, valid pointer otherwise
EXPORT_API
TWString*
TWSolanaAddressDefaultTokenAddressNative(struct TWSolanaAddress* address,
                                         TWString* tokenMintAddress)
{
    return TWSolanaAddressDefaultTokenAddress(address, tokenMintAddress);
}

/// Returns the address string representation.
///
/// \param address Non-null pointer to a Solana Address
/// \return Non-null pointer to the Solana address string representation
EXPORT_API
TWString* TWSolanaAddressDescriptionNative(struct TWSolanaAddress* address)
{
    return TWSolanaAddressDescription(address);
};