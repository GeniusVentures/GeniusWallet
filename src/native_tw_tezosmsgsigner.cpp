#include "TWTezosMessageSigner.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Implement format input as described in https://tezostaquito.io/docs/signing/
///
/// \param message message to format e.g: Hello, World
/// \param dAppUrl the app url, e.g: testUrl
/// \returns the formatted message as a string
EXPORT_API
TWString* TWTezosMessageSignerFormatMessageNative(TWString* message,
                                                  TWString* url)
{
    return TWTezosMessageSignerFormatMessage(message, url);
}

/// Implement input to payload as described in: https://tezostaquito.io/docs/signing/
///
/// \param message formatted message to be turned into an hex payload
/// \return the hexpayload of the formated message as a hex string
EXPORT_API
TWString* TWTezosMessageSignerInputToPayloadNative(TWString* message)
{
    return TWTezosMessageSignerInputToPayload(message);
}

/// Sign a message as described in https://tezostaquito.io/docs/signing/
///
/// \param privateKey: the private key used for signing
/// \param message: A custom message payload (hex) which is input to the signing.
/// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
EXPORT_API
TWString*
TWTezosMessageSignerSignMessageNative(const struct TWPrivateKey* privateKey,
                                      TWString*                  message)
{
    return TWTezosMessageSignerSignMessage(privateKey, message);
}

/// Verify signature for a message as described in https://tezostaquito.io/docs/signing/
///
/// \param pubKey: pubKey that will verify the message from the signature
/// \param message: the message signed as a payload (hex)
/// \param signature: in Base58-encoded form.
/// \returns false on any invalid input (does not throw), true if the message can be verified from the signature
EXPORT_API
bool TWTezosMessageSignerVerifyMessageNative(const struct TWPublicKey* pubKey,
                                             TWString* message,
                                             TWString* signature)
{
    return TWTezosMessageSignerVerifyMessage(pubKey, message, signature);
}
