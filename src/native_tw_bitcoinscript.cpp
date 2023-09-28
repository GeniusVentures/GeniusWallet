#include "TWBitcoinScript.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Creates an empty script.
///
/// \return A pointer to the script
EXPORT_API
struct TWBitcoinScript* TWBitcoinScriptCreateNative()
{
    return TWBitcoinScriptCreate();
}

/// Creates a script from a raw data representation.
///
/// \param data The data buffer
/// \note Must be deleted with \TWBitcoinScriptDelete
/// \return A pointer to the script
EXPORT_API
struct TWBitcoinScript* TWBitcoinScriptCreateWithDataNative(TWData* data)
{
    return TWBitcoinScriptCreateWithData(data);
}

/// Creates a script from a raw bytes and size.
///
/// \param bytes The buffer
/// \param size The size of the buffer
/// \note Must be deleted with \TWBitcoinScriptDelete
/// \return A pointer to the script
EXPORT_API
struct TWBitcoinScript* TWBitcoinScriptCreateWithBytesNative(uint8_t* bytes,
                                                             size_t   size)
{
    return TWBitcoinScriptCreateWithBytes(bytes, size);
}

/// Creates a script by copying an existing script.
///
/// \param script Non-null pointer to a script
/// \note Must be deleted with \TWBitcoinScriptDelete
/// \return A pointer to the script
EXPORT_API
struct TWBitcoinScript*
TWBitcoinScriptCreateCopyNative(const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptCreateCopy(script);
}

/// Delete/Deallocate a given script.
///
/// \param script Non-null pointer to a script
EXPORT_API
void TWBitcoinScriptDeleteNative(struct TWBitcoinScript* script)
{
    TWBitcoinScriptDelete(script);
}

/// Get size of a script
///
/// \param script Non-null pointer to a script
/// \return size of the script
EXPORT_API
size_t TWBitcoinScriptSizeNative(const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptSize(script);
}

/// Get data of a script
///
/// \param script Non-null pointer to a script
/// \return data of the given script
EXPORT_API
TWData* TWBitcoinScriptDataNative(const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptData(script);
}

/// Return script hash of a script
///
/// \param script Non-null pointer to a script
/// \return script hash of the given script
EXPORT_API
TWData* TWBitcoinScriptScriptHashNative(const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptScriptHash(script);
}

/// Determines whether this is a pay-to-script-hash (P2SH) script.
///
/// \param script Non-null pointer to a script
/// \return true if this is a pay-to-script-hash (P2SH) script, false otherwise
EXPORT_API
bool TWBitcoinScriptIsPayToScriptHashNative(
    const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptIsPayToScriptHash(script);
}

/// Determines whether this is a pay-to-witness-script-hash (P2WSH) script.
///
/// \param script Non-null pointer to a script
/// \return true if this is a pay-to-witness-script-hash (P2WSH) script, false otherwise
EXPORT_API
bool TWBitcoinScriptIsPayToWitnessScriptHashNative(
    const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptIsPayToWitnessScriptHash(script);
}

/// Determines whether this is a pay-to-witness-public-key-hash (P2WPKH) script.
///
/// \param script Non-null pointer to a script
/// \return true if this is a pay-to-witness-public-key-hash (P2WPKH) script, false otherwise
EXPORT_API
bool TWBitcoinScriptIsPayToWitnessPublicKeyHashNative(
    const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptIsPayToWitnessPublicKeyHash(script);
}

/// Determines whether this is a witness program script.
///
/// \param script Non-null pointer to a script
/// \return true if this is a witness program script, false otherwise
EXPORT_API
bool TWBitcoinScriptIsWitnessProgramNative(
    const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptIsWitnessProgram(script);
}

/// Determines whether 2 scripts have the same content
///
/// \param lhs Non-null pointer to the first script
/// \param rhs Non-null pointer to the second script
/// \return true if both script have the same content
EXPORT_API
bool TWBitcoinScriptEqualNative(const struct TWBitcoinScript* lhs,
                                const struct TWBitcoinScript* rhs)
{
    return TWBitcoinScriptEqual(lhs, rhs);
}

/// Matches the script to a pay-to-public-key (P2PK) script.
///
/// \param script Non-null pointer to a script
/// \return The public key.
EXPORT_API
TWData*
TWBitcoinScriptMatchPayToPubkeyNative(const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptMatchPayToPubkey(script);
}

/// Matches the script to a pay-to-public-key-hash (P2PKH).
///
/// \param script Non-null pointer to a script
/// \return the key hash.
EXPORT_API
TWData* TWBitcoinScriptMatchPayToPubkeyHashNative(
    const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptMatchPayToPubkeyHash(script);
}

/// Matches the script to a pay-to-script-hash (P2SH).
///
/// \param script Non-null pointer to a script
/// \return the script hash.
EXPORT_API
TWData* TWBitcoinScriptMatchPayToScriptHashNative(
    const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptMatchPayToScriptHash(script);
}

/// Matches the script to a pay-to-witness-public-key-hash (P2WPKH).
///
/// \param script Non-null pointer to a script
/// \return the key hash.
EXPORT_API
TWData* TWBitcoinScriptMatchPayToWitnessPublicKeyHashNative(
    const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptMatchPayToWitnessPublicKeyHash(script);
}

/// Matches the script to a pay-to-witness-script-hash (P2WSH).
///
/// \param script Non-null pointer to a script
/// \return the script hash, a SHA256 of the witness script..
EXPORT_API
TWData* TWBitcoinScriptMatchPayToWitnessScriptHashNative(
    const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptMatchPayToWitnessScriptHash(script);
}

/// Encodes the script.
///
/// \param script Non-null pointer to a script
/// \return The encoded script
EXPORT_API
TWData* TWBitcoinScriptEncodeNative(const struct TWBitcoinScript* script)
{
    return TWBitcoinScriptEncode(script);
}

/// Builds a standard 'pay to public key' script.
///
/// \param pubkey Non-null pointer to a pubkey
/// \note Must be deleted with \TWBitcoinScriptDelete
/// \return A pointer to the built script
EXPORT_API
struct TWBitcoinScript*
TWBitcoinScriptBuildPayToPublicKeyNative(TWData* pubkey)
{
    return TWBitcoinScriptBuildPayToPublicKey(pubkey);
}

/// Builds a standard 'pay to public key hash' script.
///
/// \param hash Non-null pointer to a PublicKey hash
/// \note Must be deleted with \TWBitcoinScriptDelete
/// \return A pointer to the built script
EXPORT_API
struct TWBitcoinScript*
TWBitcoinScriptBuildPayToPublicKeyHashNative(TWData* hash)
{
    return TWBitcoinScriptBuildPayToPublicKeyHash(hash);
}

/// Builds a standard 'pay to script hash' script.
///
/// \param scriptHash Non-null pointer to a script hash
/// \note Must be deleted with \TWBitcoinScriptDelete
/// \return A pointer to the built script
EXPORT_API
struct TWBitcoinScript*
TWBitcoinScriptBuildPayToScriptHashNative(TWData* scriptHash)
{
    return TWBitcoinScriptBuildPayToScriptHash(scriptHash);
}

/// Builds a pay-to-witness-public-key-hash (P2WPKH) script..
///
/// \param hash Non-null pointer to a witness public key hash
/// \note Must be deleted with \TWBitcoinScriptDelete
/// \return A pointer to the built script
EXPORT_API
struct TWBitcoinScript*
TWBitcoinScriptBuildPayToWitnessPubkeyHashNative(TWData* hash)
{
    return TWBitcoinScriptBuildPayToWitnessPubkeyHash(hash);
}

/// Builds a pay-to-witness-script-hash (P2WSH) script.
///
/// \param scriptHash Non-null pointer to a script hash
/// \note Must be deleted with \TWBitcoinScriptDelete
/// \return A pointer to the built script
EXPORT_API
struct TWBitcoinScript*
TWBitcoinScriptBuildPayToWitnessScriptHashNative(TWData* scriptHash)
{
    return TWBitcoinScriptBuildPayToWitnessScriptHash(scriptHash);
}

/// Builds a appropriate lock script for the given address..
///
/// \param address Non-null pointer to an address
/// \param coin coin type
/// \note Must be deleted with \TWBitcoinScriptDelete
/// \return A pointer to the built script
EXPORT_API
struct TWBitcoinScript*
TWBitcoinScriptLockScriptForAddressNative(TWString*       address,
                                          enum TWCoinType coin)
{
    return TWBitcoinScriptLockScriptForAddress(address, coin);
}

/// Return the default HashType for the given coin, such as TWBitcoinSigHashTypeAll.
///
/// \param coinType coin type
/// \return default HashType for the given coin
EXPORT_API
uint32_t TWBitcoinScriptHashTypeForCoinNative(enum TWCoinType coinType)
{
    return TWBitcoinScriptHashTypeForCoin(coinType);
}
