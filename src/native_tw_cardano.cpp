#include "TWCardano.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Calculates the minimum ADA amount needed for a UTXO.
///
/// \deprecated consider using `TWCardanoOutputMinAdaAmount` instead.
/// \see reference https://docs.cardano.org/native-tokens/minimum-ada-value-requirement
/// \param tokenBundle serialized data of TW.Cardano.Proto.TokenBundle.
/// \return the minimum ADA amount.
EXPORT_API
uint64_t TWCardanoMinAdaAmountNative(TWData* tokenBundle)
{
    return TWCardanoMinAdaAmount(tokenBundle);
}

/// Calculates the minimum ADA amount needed for an output.
///
/// \see reference https://docs.cardano.org/native-tokens/minimum-ada-value-requirement
/// \param toAddress valid destination address, as string.
/// \param tokenBundle serialized data of TW.Cardano.Proto.TokenBundle.
/// \param coinsPerUtxoByte cost per one byte of a serialized UTXO.
/// \return the minimum ADA amount.
EXPORT_API
uint64_t TWCardanoOutputMinAdaAmountNative(TWString* toAddress,
                                           TWData*   tokenBundle,
                                           uint64_t  coinsPerUtxoByte)
{
    return TWCardanoOutputMinAdaAmount(toAddress, tokenBundle,
                                       coinsPerUtxoByte);
}

/// Return the staking address associated to (contained in) this address. Must be a Base address.
/// Empty string is returned on error. Result must be freed.
/// \param baseAddress A valid base address, as string.
/// \return the associated staking (reward) address, as string, or empty string on error.
EXPORT_API
TWString* TWCardanoGetStakingAddressNative(TWString* baseAddress)
{
    return TWCardanoGetStakingAddress(baseAddress);
}