#include "TWEthereumMessageSigner.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Sign a typed message EIP-712 V4.
///
/// \param privateKey: the private key used for signing
/// \param messageJson: A custom typed data message in json
/// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
EXPORT_API
TWString* TWEthereumMessageSignerSignTypedMessageNative(
    const struct TWPrivateKey* privateKey, TWString* messageJson)
{
    return TWEthereumMessageSignerSignTypedMessage(privateKey, messageJson);
}

/// Sign a typed message EIP-712 V4 with EIP-155 replay attack protection.
///
/// \param privateKey: the private key used for signing
/// \param messageJson: A custom typed data message in json
/// \param chainId: chainId for eip-155 protection
/// \returns the signature, Hex-encoded. On invalid input empty string is returned or invalid chainId error message. Returned object needs to be deleted after use.
EXPORT_API
TWString* TWEthereumMessageSignerSignTypedMessageEip155Native(
    const struct TWPrivateKey* privateKey, TWString* messageJson, int chainId)
{
    return TWEthereumMessageSignerSignTypedMessageEip155(
        privateKey, messageJson, chainId);
}

/// Sign a message.
///
/// \param privateKey: the private key used for signing
/// \param message: A custom message which is input to the signing.
/// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
EXPORT_API
TWString* TWEthereumMessageSignerSignMessageNative(
    const struct TWPrivateKey* privateKey, TWString* message)
{
    return TWEthereumMessageSignerSignMessage(privateKey, message);
}

/// Sign a message with Immutable X msg type.
///
/// \param privateKey: the private key used for signing
/// \param message: A custom message which is input to the signing.
/// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
EXPORT_API
TWString* TWEthereumMessageSignerSignMessageImmutableXNative(
    const struct TWPrivateKey* privateKey, TWString* message)
{
    return TWEthereumMessageSignerSignMessageImmutableX(privateKey, message);
}

/// Sign a message with Eip-155 msg type.
///
/// \param privateKey: the private key used for signing
/// \param message: A custom message which is input to the signing.
/// \param chainId: chainId for eip-155 protection
/// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
EXPORT_API
TWString* TWEthereumMessageSignerSignMessageEip155Native(
    const struct TWPrivateKey* privateKey, TWString* message, int chainId)
{
    return TWEthereumMessageSignerSignMessageEip155(privateKey, message,
                                                    chainId);
}

/// Verify signature for a message.
///
/// \param pubKey: pubKey that will verify and recover the message from the signature
/// \param message: the message signed (without prefix)
/// \param signature: in Hex-encoded form.
/// \returns false on any invalid input (does not throw), true if the message can be recovered from the signature
EXPORT_API
bool TWEthereumMessageSignerVerifyMessageNative(
    const struct TWPublicKey* pubKey, TWString* message, TWString* signature)
{
    return TWEthereumMessageSignerVerifyMessage(pubKey, message, signature);
}
