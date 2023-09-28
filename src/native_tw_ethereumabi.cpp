#include "TWEthereumAbi.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Encode function to Eth ABI binary
///
/// \param fn Non-null Eth abi function
/// \return Non-null encoded block of data
EXPORT_API
TWData* TWEthereumAbiEncodeNative(struct TWEthereumAbiFunction* fn)
{
    return TWEthereumAbiEncode(fn);
};

/// Decode function output from Eth ABI binary, fill output parameters
///
/// \param[in] fn Non-null Eth abi function
/// \param[out] encoded Non-null block of data
/// \return true if encoded have been filled correctly, false otherwise
EXPORT_API
bool TWEthereumAbiDecodeOutputNative(struct TWEthereumAbiFunction* fn,
                                     TWData*                       encoded)
{
    return TWEthereumAbiDecodeOutput(fn, encoded);
};

/// Decode function call data to human readable json format, according to input abi json
///
/// \param data Non-null block of data
/// \param abi Non-null string
/// \return Non-null json string function call data
EXPORT_API
TWString* TWEthereumAbiDecodeCallNative(TWData* data, TWString* abi)
{
    return TWEthereumAbiDecodeCall(data, abi);
};

/// Compute the hash of a struct, used for signing, according to EIP712 ("v4").
/// Input is a Json object (as string), with following fields:
/// - types: map of used struct types (see makeTypesNative() { return makeTypes(); })
/// - primaryType: the type of the message (string)
/// - domain: EIP712 domain specifier values
/// - message: the message (object).
/// Throws on error.
/// Example input:
///  R"({
///     "types": {
///         "EIP712Domain": [
///             {"name": "name", "type": "string"},
///             {"name": "version", "type": "string"},
///             {"name": "chainId", "type": "uint256"},
///             {"name": "verifyingContract", "type": "address"}
///         ],
///         "Person": [
///             {"name": "name", "type": "string"},
///             {"name": "wallet", "type": "address"}
///         ]
///     },
///     "primaryType": "Person",
///     "domain": {
///         "name": "Ether Person",
///         "version": "1",
///         "chainId": 1,
///         "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
///     },
///     "message": {
///         "name": "Cow",
///         "wallet": "CD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
///     }
///  })");
/// On error, empty Data is returned.
/// Returned data must be deleted (hint: use WRAPDNative() { return WRAPD(); } macro).
///
/// \param messageJson Non-null json abi input
/// \return Non-null block of data, encoded abi input
EXPORT_API
TWData* TWEthereumAbiEncodeTypedNative(TWString* messageJson)
{
    return TWEthereumAbiEncodeTyped(messageJson);
};
