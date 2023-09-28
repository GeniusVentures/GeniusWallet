#include "TWStarkWare.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Generates the private stark key at the given derivation path from a valid eth signature
///
/// \param derivationPath non-null StarkEx Derivation path
/// \param signature valid eth signature
/// \return  The private key for the specified derivation path/signature
EXPORT_API
struct TWPrivateKey* TWStarkWareGetStarkKeyFromSignatureNative(
    const struct TWDerivationPath* derivationPath, TWString* signature)
{
    return TWStarkWareGetStarkKeyFromSignature(derivationPath, signature);
};