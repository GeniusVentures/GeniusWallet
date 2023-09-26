#include "TWFilecoinAddressConverter.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/**
 * @brief       Converts a Filecoin address to Ethereum.
 * @param[in]   filecoinAddress A Filecoin address.
 * @return      The Ethereum address. On invalid input empty string is returned. 
 * @note        Returned object needs to be deleted after use.
 */
EXPORT_API
TWString*
TWFilecoinAddressConverterConvertToEthereumNative(TWString* filecoinAddress)
{
    return TWFilecoinAddressConverterConvertToEthereum(filecoinAddress);
}

/**
 * @brief       Converts an Ethereum address to Filecoin.
 * @param[in]   ethAddress An Ethereum address.
 * @return      The Filecoin address. On invalid input empty string is returned.
 * @note        Returned object needs to be deleted after use.
 */
EXPORT_API
TWString*
TWFilecoinAddressConverterConvertFromEthereumNative(TWString* ethAddress)
{
    return TWFilecoinAddressConverterConvertFromEthereum(ethAddress);
}
