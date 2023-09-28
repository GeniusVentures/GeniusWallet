#include "TWBase64.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Decode a Base64 input with the default alphabet (RFC4648 with '+', '/')
///
/// \param string Encoded input to be decoded
/// \return The decoded data, empty if decoding failed.
EXPORT_API
TWData* TWBase64DecodeNative(TWString* string)
{
    return TWBase64Decode(string);
}

/// Decode a Base64 input with the alphabet safe for URL-s and filenames (RFC4648 with '-', '_')
///
/// \param string Encoded base64 input to be decoded
/// \return The decoded data, empty if decoding failed.
EXPORT_API
TWData* TWBase64DecodeUrlNative(TWString* string)
{
    return TWBase64DecodeUrl(string);
}

/// Encode an input to Base64 with the default alphabet (RFC4648 with '+', '/')
///
/// \param data Data to be encoded (raw bytes)
/// \return The encoded data
EXPORT_API
TWString* TWBase64EncodeNative(TWData* data)
{
    return TWBase64Encode(data);
}

/// Encode an input to Base64 with the alphabet safe for URL-s and filenames (RFC4648 with '-', '_')
///
/// \param data Data to be encoded (raw bytes)
/// \return The encoded data
EXPORT_API
TWString* TWBase64EncodeUrlNative(TWData* data)
{
    return TWBase64EncodeUrl(data);
}