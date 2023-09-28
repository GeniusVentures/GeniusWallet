#include "TWPrivateKey.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

extern "C" const size_t TWPrivateKeySizeNative = TWPrivateKeySize;

/// Create a random private key
///
/// \note Should be deleted with \TWPrivateKeyDelete
/// \return Non-null Private key
EXPORT_API
struct TWPrivateKey* TWPrivateKeyCreateNative(void)
{
    return TWPrivateKeyCreate();
}

/// Create a private key with the given block of data
///
/// \param data a block of data
/// \note Should be deleted with \TWPrivateKeyDelete
/// \return Nullable pointer to Private Key
EXPORT_API
struct TWPrivateKey* TWPrivateKeyCreateWithDataNative(TWData* data)
{
    return TWPrivateKeyCreateWithData(data);
}

/// Deep copy a given private key
///
/// \param key Non-null private key to be copied
/// \note Should be deleted with \TWPrivateKeyDelete
/// \return Deep copy, Nullable pointer to Private key
EXPORT_API
struct TWPrivateKey* TWPrivateKeyCreateCopyNative(struct TWPrivateKey* key)
{
    return TWPrivateKeyCreateCopy(key);
}

/// Delete the given private key
///
/// \param pk Non-null pointer to private key
EXPORT_API
void TWPrivateKeyDeleteNative(struct TWPrivateKey* pk)
{
    TWPrivateKeyDelete(pk);
}

/// Determines if the given private key is valid or not.
///
/// \param data block of data (private key bytes)
/// \param curve Eliptic curve of the private key
/// \return true if the private key is valid, false otherwise
EXPORT_API
bool TWPrivateKeyIsValidNative(TWData* data, enum TWCurve curve)
{
    return TWPrivateKeyIsValid(data, curve);
}

/// Convert the given private key to raw-bytes block of data
///
/// \param pk Non-null pointer to the private key
/// \return Non-null block of data (raw bytes) of the given private key
EXPORT_API
TWData* TWPrivateKeyDataNative(struct TWPrivateKey* pk)
{
    return TWPrivateKeyData(pk);
}

/// Returns the public key associated with the given coinType and privateKey
///
/// \param pk Non-null pointer to the private key
/// \param coinType coinType of the given private key
/// \return Non-null pointer to the corresponding public key
EXPORT_API
struct TWPublicKey* TWPrivateKeyGetPublicKeyNative(struct TWPrivateKey* pk,
                                                   enum TWCoinType coinType)
{
    return TWPrivateKeyGetPublicKey(pk, coinType);
}

/// Returns the public key associated with the given pubkeyType and privateKey
///
/// \param pk Non-null pointer to the private key
/// \param pubkeyType pubkeyType of the given private key
/// \return Non-null pointer to the corresponding public key
EXPORT_API
struct TWPublicKey*
TWPrivateKeyGetPublicKeyByTypeNative(struct TWPrivateKey* pk,
                                     enum TWPublicKeyType pubkeyType)
{
    return TWPrivateKeyGetPublicKeyByType(pk, pubkeyType);
}

/// Returns the Secp256k1 public key associated with the given private key
///
/// \param pk Non-null pointer to the private key
/// \param compressed if the given private key is compressed or not
/// \return Non-null pointer to the corresponding public key
EXPORT_API
struct TWPublicKey*
TWPrivateKeyGetPublicKeySecp256k1Native(struct TWPrivateKey* pk,
                                        bool                 compressed)
{
    return TWPrivateKeyGetPublicKeySecp256k1(pk, compressed);
}

/// Returns the Nist256p1 public key associated with the given private key
///
/// \param pk Non-null pointer to the private key
/// \return Non-null pointer to the corresponding public key
EXPORT_API
struct TWPublicKey*
TWPrivateKeyGetPublicKeyNist256p1Native(struct TWPrivateKey* pk)
{
    return TWPrivateKeyGetPublicKeyNist256p1(pk);
}

/// Returns the Ed25519 public key associated with the given private key
///
/// \param pk Non-null pointer to the private key
/// \return Non-null pointer to the corresponding public key
EXPORT_API
struct TWPublicKey*
TWPrivateKeyGetPublicKeyEd25519Native(struct TWPrivateKey* pk)
{
    return TWPrivateKeyGetPublicKeyEd25519(pk);
}

/// Returns the Ed25519Blake2b public key associated with the given private key
///
/// \param pk Non-null pointer to the private key
/// \return Non-null pointer to the corresponding public key
EXPORT_API
struct TWPublicKey*
TWPrivateKeyGetPublicKeyEd25519Blake2bNative(struct TWPrivateKey* pk)
{
    return TWPrivateKeyGetPublicKeyEd25519Blake2b(pk);
}

/// Returns the Ed25519Cardano public key associated with the given private key
///
/// \param pk Non-null pointer to the private key
/// \return Non-null pointer to the corresponding public key
EXPORT_API
struct TWPublicKey*
TWPrivateKeyGetPublicKeyEd25519CardanoNative(struct TWPrivateKey* pk)
{
    return TWPrivateKeyGetPublicKeyEd25519Cardano(pk);
}

/// Returns the Curve25519 public key associated with the given private key
///
/// \param pk Non-null pointer to the private key
/// \return Non-null pointer to the corresponding public key
EXPORT_API
struct TWPublicKey*
TWPrivateKeyGetPublicKeyCurve25519Native(struct TWPrivateKey* pk)
{
    return TWPrivateKeyGetPublicKeyCurve25519(pk);
}

/// Computes an EC Diffie-Hellman secret in constant time
/// Supported curves: secp256k1
///
/// \param pk Non-null pointer to a Private key
/// \param publicKey Non-null pointer to the corresponding public key
/// \param curve Eliptic curve
/// \return The corresponding shared key as a non-null block of data
EXPORT_API
TWData* TWPrivateKeyGetSharedKeyNative(const struct TWPrivateKey* pk,
                                       const struct TWPublicKey*  publicKey,
                                       enum TWCurve               curve)
{
    return TWPrivateKeyGetSharedKey(pk, publicKey, curve);
}

/// Signs a digest using ECDSA and given curve.
///
/// \param pk  Non-null pointer to a Private key
/// \param digest Non-null digest block of data
/// \param curve Eliptic curve
/// \return Signature as a Non-null block of data
EXPORT_API
TWData* TWPrivateKeySignNative(struct TWPrivateKey* pk, TWData* digest,
                               enum TWCurve curve)
{
    return TWPrivateKeySign(pk, digest, curve);
}

/// Signs a digest using ECDSA. The result is encoded with DER.
///
/// \param pk  Non-null pointer to a Private key
/// \param digest Non-null digest block of data
/// \return Signature as a Non-null block of data
EXPORT_API
TWData* TWPrivateKeySignAsDERNative(struct TWPrivateKey* pk, TWData* digest)
{
    return TWPrivateKeySignAsDER(pk, digest);
}

/// Signs a digest using ECDSA and Zilliqa schnorr signature scheme.
///
/// \param pk Non-null pointer to a Private key
/// \param message Non-null message
/// \return Signature as a Non-null block of data
EXPORT_API
TWData* TWPrivateKeySignZilliqaSchnorrNative(struct TWPrivateKey* pk,
                                             TWData*              message)
{
    return TWPrivateKeySignZilliqaSchnorr(pk, message);
}