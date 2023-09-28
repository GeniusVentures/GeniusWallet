#include "TWEthereum.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Generate a layer 2 eip2645 derivation path from eth address, layer, application and given index.
///
/// \param wallet non-null TWHDWallet
/// \param ethAddress non-null Ethereum address
/// \param layer  non-null layer 2 name (E.G starkex)
/// \param application non-null layer 2 application (E.G immutablex)
/// \param index non-null layer 2 index (E.G 1)
/// \return a valid eip2645 layer 2 derivation path as a string
EXPORT_API
TWString* TWEthereumEip2645GetPathNative(TWString* ethAddress,
                                         TWString* layer,
                                         TWString* application,
                                         TWString* index)
{
    return TWEthereumEip2645GetPath(ethAddress, layer, application, index);
}

/// Generates a deployment address for a ERC-4337 compatible smart contract wallet
///
/// \param factoryAddress non-null address of the account factory
/// \param logicAddress non-null address of the wallet's logic smart contract
/// \param ownerAddress  non-null address of the signing key that controls the smart contract wallet
/// \return Ethereum resulting address
EXPORT_API
TWString* TWEthereumEip4337GetDeploymentAddressNative(
    TWString* factoryAddress, TWString* logicAddress, TWString* ownerAddress)
{
    return TWEthereumEip4337GetDeploymentAddress(factoryAddress, logicAddress,
                                                 ownerAddress);
}
