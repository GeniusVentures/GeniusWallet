#include "TWBitcoinSigHashType.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Determines if the given sig hash is single
///
/// \param type sig hash type
/// \return true if the sigh hash type is single, false otherwise
EXPORT_API
bool TWBitcoinSigHashTypeIsSingleNative(enum TWBitcoinSigHashType type)
{
    return TWBitcoinSigHashTypeIsSingle(type);
}

/// Determines if the given sig hash is none
///
/// \param type sig hash type
/// \return true if the sigh hash type is none, false otherwise
EXPORT_API
bool TWBitcoinSigHashTypeIsNoneNative(enum TWBitcoinSigHashType type)
{
    return TWBitcoinSigHashTypeIsNone(type);
}
