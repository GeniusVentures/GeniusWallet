#include "TWBase32.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Decode a Base32 input with the given alphabet
///
/// \param string Encoded base32 input to be decoded
/// \param alphabet Decode with the given alphabet, if nullptr ALPHABET_RFC4648 is used by default
/// \return The decoded data, can be null.
/// \note ALPHABET_RFC4648 doesn't support padding in the default alphabet
EXPORT_API
TWData* TWBase32DecodeWithAlphabetNative(TWString* string, TWString* alphabet)
{
    return TWBase32DecodeWithAlphabet(string, alphabet);
}

/// Decode a Base32 input with the default alphabet (ALPHABET_RFC4648)
///
/// \param string Encoded input to be decoded
/// \return The decoded data
/// \note Call TWBase32DecodeWithAlphabet with nullptr.
EXPORT_API
TWData* TWBase32DecodeNative(TWString* string)
{
    return TWBase32Decode(string);
}

/// Encode an input to Base32 with the given alphabet
///
/// \param data Data to be encoded (raw bytes)
/// \param alphabet Encode with the given alphabet, if nullptr ALPHABET_RFC4648 is used by default
/// \return The encoded data
/// \note ALPHABET_RFC4648 doesn't support padding in the default alphabet
EXPORT_API
TWString* TWBase32EncodeWithAlphabetNative(TWData* data, TWString* alphabet)
{
    return TWBase32EncodeWithAlphabet(data, alphabet);
}

/// Encode an input to Base32 with the default alphabet (ALPHABET_RFC4648)
///
/// \param data Data to be encoded (raw bytes)
/// \return The encoded data
/// \note Call TWBase32EncodeWithAlphabet with nullptr.
EXPORT_API
TWString* TWBase32EncodeNative(TWData* data)
{
    return TWBase32Encode(data);
}
