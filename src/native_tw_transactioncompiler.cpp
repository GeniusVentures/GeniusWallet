#include "TWTransactionCompiler.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Obtains pre-signing hashes of a transaction.
///
/// We provide a default `PreSigningOutput` in TransactionCompiler.proto.
/// For some special coins, such as bitcoin, we will create a custom `PreSigningOutput` object in its proto file.
/// \param coin coin type.
/// \param txInputData The serialized data of a signing input
/// \return serialized data of a proto object `PreSigningOutput` includes hash.
EXPORT_API
TWData* TWTransactionCompilerPreImageHashesNative(enum TWCoinType coinType,
                                                  TWData*         txInputData)
{
    return TWTransactionCompilerPreImageHashes(coinType, txInputData);
}

/// Compiles a complete transation with one or more external signatures.
///
/// Puts together from transaction input and provided public keys and signatures. The signatures must match the hashes
/// returned by TWTransactionCompilerPreImageHashes, in the same order. The publicKeyHash attached
/// to the hashes enable identifying the private key needed for signing the hash.
/// \param coin coin type.
/// \param txInputData The serialized data of a signing input.
/// \param signatures signatures to compile, using TWDataVector.
/// \param publicKeys public keys for signers to match private keys, using TWDataVector.
/// \return serialized data of a proto object `SigningOutput`.
EXPORT_API
TWData* TWTransactionCompilerCompileWithSignaturesNative(
    enum TWCoinType coinType, TWData* txInputData,
    const struct TWDataVector* signatures,
    const struct TWDataVector* publicKeys)
{
    return TWTransactionCompilerCompileWithSignatures(coinType, txInputData,
                                                      signatures, publicKeys);
}
