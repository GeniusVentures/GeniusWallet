#include "TWEthereumAbiValue.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Encode a bool according to Ethereum ABI, into 32 bytes.  Values are padded by 0 on the left, unless specified otherwise
///
/// \param value a boolean value
/// \return Encoded value stored in a block of data
EXPORT_API
TWData* TWEthereumAbiValueEncodeBoolNative(bool value)
{
    return TWEthereumAbiValueEncodeBool(value);
}

/// Encode a int32 according to Ethereum ABI, into 32 bytes. Values are padded by 0 on the left, unless specified otherwise
///
/// \param value a int32 value
/// \return Encoded value stored in a block of data
EXPORT_API
TWData* TWEthereumAbiValueEncodeInt32Native(int32_t value)
{
    return TWEthereumAbiValueEncodeInt32(value);
}

/// Encode a uint32 according to Ethereum ABI, into 32 bytes.  Values are padded by 0 on the left, unless specified otherwise
///
/// \param value a uint32 value
/// \return Encoded value stored in a block of data
EXPORT_API
TWData* TWEthereumAbiValueEncodeUInt32Native(uint32_t value)
{
    return TWEthereumAbiValueEncodeUInt32(value);
}

/// Encode a int256 according to Ethereum ABI, into 32 bytes.  Values are padded by 0 on the left, unless specified otherwise
///
/// \param value a int256 value stored in a block of data
/// \return Encoded value stored in a block of data
EXPORT_API
TWData* TWEthereumAbiValueEncodeInt256Native(TWData* value)
{
    return TWEthereumAbiValueEncodeInt256(value);
}

/// Encode an int256 according to Ethereum ABI, into 32 bytes.  Values are padded by 0 on the left, unless specified otherwise
///
/// \param value a int256 value stored in a block of data
/// \return Encoded value stored in a block of data
EXPORT_API
TWData* TWEthereumAbiValueEncodeUInt256Native(TWData* value)
{
    return TWEthereumAbiValueEncodeUInt256(value);
}

/// Encode an address according to Ethereum ABI, 20 bytes of the address.
///
/// \param value an address value stored in a block of data
/// \return Encoded value stored in a block of data
EXPORT_API
TWData* TWEthereumAbiValueEncodeAddressNative(TWData* value)
{
    return TWEthereumAbiValueEncodeAddress(value);
}

/// Encode a string according to Ethereum ABI by encoding its hash.
///
/// \param value a string value
/// \return Encoded value stored in a block of data
EXPORT_API
TWData* TWEthereumAbiValueEncodeStringNative(TWString* value)
{
    return TWEthereumAbiValueEncodeString(value);
}

/// Encode a number of bytes, up to 32 bytes, padded on the right.  Longer arrays are truncated.
///
/// \param value bunch of bytes
/// \return Encoded value stored in a block of data
EXPORT_API
TWData* TWEthereumAbiValueEncodeBytesNative(TWData* value)
{
    return TWEthereumAbiValueEncodeBytes(value);
}

/// Encode a dynamic number of bytes by encoding its hash
///
/// \param value bunch of bytes
/// \return Encoded value stored in a block of data
EXPORT_API
TWData* TWEthereumAbiValueEncodeBytesDynNative(TWData* value)
{
    return TWEthereumAbiValueEncodeBytesDyn(value);
}

/// Decodes input data (bytes longer than 32 will be truncated) as uint256
///
/// \param input Data to be decoded
/// \return Non-null decoded string value
EXPORT_API
TWString* TWEthereumAbiValueDecodeUInt256Native(TWData* input)
{
    return TWEthereumAbiValueDecodeUInt256(input);
}

/// Decode an arbitrary type, return value as string
///
/// \param input Data to be decoded
/// \param type the underlying type that need to be decoded
/// \return Non-null decoded string value
EXPORT_API
TWString* TWEthereumAbiValueDecodeValueNative(TWData* input, TWString* type)
{
    return TWEthereumAbiValueDecodeValue(input, type);
}

/// Decode an array of given simple types.  Return a '\n'-separated string of elements
///
/// \param input Data to be decoded
/// \param type the underlying type that need to be decoded
/// \return Non-null decoded string value
EXPORT_API
TWString* TWEthereumAbiValueDecodeArrayNative(TWData* input, TWString* type)
{
    return TWEthereumAbiValueDecodeArray(input, type);
}
