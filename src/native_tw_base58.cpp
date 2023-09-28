#include "TWBase58.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Encodes data as a Base58 string, including the checksum.
///
/// \param data The data to encode.
/// \return the encoded Base58 string with checksum.
EXPORT_API
TWString* TWBase58EncodeNative(TWData* data)
{
    return TWBase58Encode(data);
}

/// Encodes data as a Base58 string, not including the checksum.
///
/// \param data The data to encode.
/// \return then encoded Base58 string without checksum.
EXPORT_API
TWString* TWBase58EncodeNoCheckNative(TWData* data)
{
    return TWBase58EncodeNoCheck(data);
}

/// Decodes a Base58 string, checking the checksum. Returns null if the string is not a valid Base58 string.
///
/// \param string The Base58 string to decode.
/// \return the decoded data, empty if the string is not a valid Base58 string with checksum.
EXPORT_API
TWData* TWBase58DecodeNative(TWString* string)
{
    return TWBase58Decode(string);
}

/// Decodes a Base58 string, w/o checking the checksum. Returns null if the string is not a valid Base58 string.
///
/// \param string The Base58 string to decode.
/// \return the decoded data, empty if the string is not a valid Base58 string without checksum.
EXPORT_API
TWData* TWBase58DecodeNoCheckNative(TWString* string)
{
    return TWBase58DecodeNoCheck(string);
}
