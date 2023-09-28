#include "TWTronMessageSigner.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Sign a message.
///
/// \param privateKey: the private key used for signing
/// \param message: A custom message which is input to the signing.
/// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
EXPORT_API
TWString*
TWTronMessageSignerSignMessageNative(const struct TWPrivateKey* privateKey,
                                     TWString*                  message)
{
    return TWTronMessageSignerSignMessage(privateKey, message);
};

/// Verify signature for a message.
///
/// \param pubKey: pubKey that will verify and recover the message from the signature
/// \param message: the message signed (without prefix)
/// \param signature: in Hex-encoded form.
/// \returns false on any invalid input (does not throw), true if the message can be recovered from the signature
EXPORT_API
bool TWTronMessageSignerVerifyMessageNative(const struct TWPublicKey* pubKey,
                                            TWString*                 message,
                                            TWString* signature)
{
    return TWTronMessageSignerVerifyMessage(pubKey, message, signature);
};