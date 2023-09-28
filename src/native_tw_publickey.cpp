#include "TWPublicKey.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

extern "C"
{
    const size_t TWPublicKeyCompressedSizeNative = TWPublicKeyCompressedSize;
    const size_t TWPublicKeyUncompressedSizeNative =
        TWPublicKeyUncompressedSize;
}

/// Create a public key from a block of data
///
/// \param data Non-null block of data representing the public key
/// \param type type of the public key
/// \note Should be deleted with \TWPublicKeyDelete
/// \return Nullable pointer to the public key
EXPORT_API
struct TWPublicKey* TWPublicKeyCreateWithDataNative(TWData*              data,
                                                    enum TWPublicKeyType type)
{
    return TWPublicKeyCreateWithData(data, type);
}

/// Delete the given public key
///
/// \param pk Non-null pointer to a public key
EXPORT_API
void TWPublicKeyDeleteNative(struct TWPublicKey* pk)
{
    TWPublicKeyDelete(pk);
}

/// Determines if the given public key is valid or not
///
/// \param data Non-null block of data representing the public key
/// \param type type of the public key
/// \return true if the block of data is a valid public key, false otherwise
EXPORT_API
bool TWPublicKeyIsValidNative(TWData* data, enum TWPublicKeyType type)
{
    return TWPublicKeyIsValid(data, type);
}

/// Determines if the given public key is compressed or not
///
/// \param pk Non-null pointer to a public key
/// \return true if the public key is compressed, false otherwise
EXPORT_API
bool TWPublicKeyIsCompressedNative(struct TWPublicKey* pk)
{
    return TWPublicKeyIsCompressed(pk);
}

/// Give the compressed public key of the given non-compressed public key
///
/// \param from Non-null pointer to a non-compressed public key
/// \return Non-null pointer to the corresponding compressed public-key
EXPORT_API
struct TWPublicKey* TWPublicKeyCompressedNative(struct TWPublicKey* from)
{
    return TWPublicKeyCompressed(from);
}

/// Give the non-compressed public key of a corresponding compressed public key
///
/// \param from Non-null pointer to the corresponding compressed public key
/// \return Non-null pointer to the corresponding non-compressed public key
EXPORT_API
struct TWPublicKey* TWPublicKeyUncompressedNative(struct TWPublicKey* from)
{
    return TWPublicKeyUncompressed(from);
}

/// Gives the raw data of a given public-key
///
/// \param pk Non-null pointer to a public key
/// \return Non-null pointer to the raw block of data of the given public key
EXPORT_API
TWData* TWPublicKeyDataNative(struct TWPublicKey* pk)
{
    return TWPublicKeyData(pk);
}

/// Verify the validity of a signature and a message using the given public key
///
/// \param pk Non-null pointer to a public key
/// \param signature Non-null pointer to a block of data corresponding to the signature
/// \param message Non-null pointer to a block of data corresponding to the message
/// \return true if the signature and the message belongs to the given public key, false otherwise
EXPORT_API
bool TWPublicKeyVerifyNative(struct TWPublicKey* pk, TWData* signature,
                             TWData* message)
{
    return TWPublicKeyVerify(pk, signature, message);
}

/// Verify the validity as DER of a signature and a message using the given public key
///
/// \param pk Non-null pointer to a public key
/// \param signature Non-null pointer to a block of data corresponding to the signature
/// \param message Non-null pointer to a block of data corresponding to the message
/// \return true if the signature and the message belongs to the given public key, false otherwise
EXPORT_API
bool TWPublicKeyVerifyAsDERNative(struct TWPublicKey* pk, TWData* signature,
                                  TWData* message)
{
    return TWPublicKeyVerifyAsDER(pk, signature, message);
}

/// Verify a Zilliqa schnorr signature with a signature and message.
///
/// \param pk Non-null pointer to a public key
/// \param signature Non-null pointer to a block of data corresponding to the signature
/// \param message Non-null pointer to a block of data corresponding to the message
/// \return true if the signature and the message belongs to the given public key, false otherwise
EXPORT_API
bool TWPublicKeyVerifyZilliqaSchnorrNative(struct TWPublicKey* pk,
                                           TWData* signature, TWData* message)
{
    return TWPublicKeyVerifyZilliqaSchnorr(pk, signature, message);
}

/// Give the public key type (eliptic) of a given public key
///
/// \param publicKey Non-null pointer to a public key
/// \return The public key type of the given public key (eliptic)
EXPORT_API
enum TWPublicKeyType TWPublicKeyKeyTypeNative(struct TWPublicKey* publicKey)
{
    return TWPublicKeyKeyType(publicKey);
}

/// Get the public key description from a given public key
///
/// \param publicKey Non-null pointer to a public key
/// \return Non-null pointer to a string representing the description of the public key
EXPORT_API
TWString* TWPublicKeyDescriptionNative(struct TWPublicKey* publicKey)
{
    return TWPublicKeyDescription(publicKey);
}

/// Try to get a public key from a given signature and a message
///
/// \param signature Non-null pointer to a block of data corresponding to the signature
/// \param message Non-null pointer to a block of data corresponding to the message
/// \return Null pointer if the public key can't be recover from the given signature and message,
/// pointer to the public key otherwise
EXPORT_API
struct TWPublicKey* TWPublicKeyRecoverNative(TWData* signature,
                                             TWData* message)
{
    return TWPublicKeyRecover(signature, message);
}