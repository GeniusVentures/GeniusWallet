#include "TWBitcoinMessageSigner.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Sign a message.
///
/// \param privateKey: the private key used for signing
/// \param address: the address that matches the privateKey, must be a legacy address (P2PKH)
/// \param message: A custom message which is input to the signing.
/// \note Address is derived assuming compressed public key format.
/// \returns the signature, Base64-encoded.  On invalid input empty string is returned. Returned object needs to be deleteed after use.
EXPORT_API
TWString*
TWBitcoinMessageSignerSignMessageNative(const struct TWPrivateKey* privateKey,
                                        TWString* address, TWString* message)
{
    return TWBitcoinMessageSignerSignMessage(privateKey, address, message);
}

/// Verify signature for a message.
///
/// \param address: address to use, only legacy is supported
/// \param message: the message signed (without prefix)
/// \param signature: in Base64-encoded form.
/// \returns false on any invalid input (does not throw).
EXPORT_API
bool TWBitcoinMessageSignerVerifyMessageNative(TWString* address,
                                               TWString* message,
                                               TWString* signature)
{
    return TWBitcoinMessageSignerVerifyMessage(address, message, signature);
}
