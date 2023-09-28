#include "TWTHORChainSwap.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Builds a THORChainSwap transaction input.
///
/// \param input The serialized data of SwapInput.
/// \return The serialized data of SwapOutput.
EXPORT_API
TWData* TWTHORChainSwapBuildSwapNative(TWData* input)
{
    return TWTHORChainSwapBuildSwap(input);
}
