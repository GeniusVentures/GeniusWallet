#include "TWEthereumAbiFunction.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Creates a function object, with the given name and empty parameter list.  It must be deleted at the end.
///
/// \param name function name
/// \return Non-null Ethereum abi function
EXPORT_API
struct TWEthereumAbiFunction*
TWEthereumAbiFunctionCreateWithStringNative(TWString* name)
{
    return TWEthereumAbiFunctionCreateWithString(name);
}

/// Deletes a function object created with a 'TWEthereumAbiFunctionCreateWithString' method.
///
/// \param fn Non-null Ethereum abi function
EXPORT_API
void TWEthereumAbiFunctionDeleteNative(struct TWEthereumAbiFunction* fn)
{
    TWEthereumAbiFunctionDelete(fn);
}

/// Return the function type signature, of the form "bazNative(int32,uint256) { return baz(int32,uint256); }"
///
/// \param fn A Non-null eth abi function
/// \return function type signature as a Non-null string.
EXPORT_API
TWString* TWEthereumAbiFunctionGetTypeNative(struct TWEthereumAbiFunction* fn)
{
    return TWEthereumAbiFunctionGetType(fn);
}

/// Methods for adding parameters of the given type (input or output).
/// For output parameters (isOutput=true) a value has to be specified, although usually not need;

/// Add a uint8 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamUInt8Native(struct TWEthereumAbiFunction* fn,
                                             uint8_t val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamUInt8(fn, val, isOutput);
}

/// Add a uint16 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamUInt16Native(
    struct TWEthereumAbiFunction* fn, uint16_t val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamUInt16(fn, val, isOutput);
}

/// Add a uint32 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamUInt32Native(
    struct TWEthereumAbiFunction* fn, uint32_t val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamUInt32(fn, val, isOutput);
}

/// Add a uint64 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamUInt64Native(
    struct TWEthereumAbiFunction* fn, uint64_t val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamUInt64(fn, val, isOutput);
}

/// Add a uint256 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamUInt256Native(
    struct TWEthereumAbiFunction* fn, TWData* val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamUInt256(fn, val, isOutput);
}

/// Add a uintNative(bits) { return uint(bits); } type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamUIntNNative(struct TWEthereumAbiFunction* fn,
                                             int bits, TWData* val,
                                             bool isOutput)
{
    return TWEthereumAbiFunctionAddParamUIntN(fn, bits, val, isOutput);
}

/// Add a int8 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamInt8Native(struct TWEthereumAbiFunction* fn,
                                            int8_t val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamInt8(fn, val, isOutput);
}

/// Add a int16 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamInt16Native(struct TWEthereumAbiFunction* fn,
                                             int16_t val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamInt16(fn, val, isOutput);
}

/// Add a int32 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamInt32Native(struct TWEthereumAbiFunction* fn,
                                             int32_t val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamInt32(fn, val, isOutput);
}

/// Add a int64 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamInt64Native(struct TWEthereumAbiFunction* fn,
                                             int64_t val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamInt64(fn, val, isOutput);
}

/// Add a int256 type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified (stored in a block of data)
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamInt256Native(
    struct TWEthereumAbiFunction* fn, TWData* val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamInt256(fn, val, isOutput);
}

/// Add a intNative(bits) { return int(bits); } type parameter
///
/// \param fn A Non-null eth abi function
/// \param bits Number of bits of the integer parameter
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamIntNNative(struct TWEthereumAbiFunction* fn,
                                            int bits, TWData* val,
                                            bool isOutput)
{
    return TWEthereumAbiFunctionAddParamIntN(fn, bits, val, isOutput);
}

/// Add a bool type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamBoolNative(struct TWEthereumAbiFunction* fn,
                                            bool val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamBool(fn, val, isOutput);
}

/// Add a string type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamStringNative(
    struct TWEthereumAbiFunction* fn, TWString* val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamString(fn, val, isOutput);
}

/// Add an address type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamAddressNative(
    struct TWEthereumAbiFunction* fn, TWData* val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamAddress(fn, val, isOutput);
}

/// Add a bytes type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamBytesNative(struct TWEthereumAbiFunction* fn,
                                             TWData* val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamBytes(fn, val, isOutput);
}

/// Add a bytes[N] type parameter
///
/// \param fn A Non-null eth abi function
/// \param size fixed size of the bytes array parameter (val).
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamBytesFixNative(
    struct TWEthereumAbiFunction* fn, size_t size, TWData* val, bool isOutput)
{
    return TWEthereumAbiFunctionAddParamBytesFix(fn, size, val, isOutput);
}

/// Add a type[] type parameter
///
/// \param fn A Non-null eth abi function
/// \param val for output parameters, value has to be specified
/// \param isOutput determines if the parameter is an input or output
/// \return the index of the parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddParamArrayNative(struct TWEthereumAbiFunction* fn,
                                             bool isOutput)
{
    return TWEthereumAbiFunctionAddParamArray(fn, isOutput);
}

/// Methods for accessing the value of an output or input parameter, of different types.

/// Get a uint8 type parameter at the given index
///
/// \param fn A Non-null eth abi function
/// \param idx index for the parameter (0-based).
/// \param isOutput determines if the parameter is an input or output
/// \return the value of the parameter.
EXPORT_API
uint8_t
TWEthereumAbiFunctionGetParamUInt8Native(struct TWEthereumAbiFunction* fn,
                                         int idx, bool isOutput)
{
    return TWEthereumAbiFunctionGetParamUInt8(fn, idx, isOutput);
}

/// Get a uint64 type parameter at the given index
///
/// \param fn A Non-null eth abi function
/// \param idx index for the parameter (0-based).
/// \param isOutput determines if the parameter is an input or output
/// \return the value of the parameter.
EXPORT_API
uint64_t
TWEthereumAbiFunctionGetParamUInt64Native(struct TWEthereumAbiFunction* fn,
                                          int idx, bool isOutput)
{
    return TWEthereumAbiFunctionGetParamUInt64(fn, idx, isOutput);
}

/// Get a uint256 type parameter at the given index
///
/// \param fn A Non-null eth abi function
/// \param idx index for the parameter (0-based).
/// \param isOutput determines if the parameter is an input or output
/// \return the value of the parameter stored in a block of data.
EXPORT_API
TWData*
TWEthereumAbiFunctionGetParamUInt256Native(struct TWEthereumAbiFunction* fn,
                                           int idx, bool isOutput)
{
    return TWEthereumAbiFunctionGetParamUInt256(fn, idx, isOutput);
}

/// Get a bool type parameter at the given index
///
/// \param fn A Non-null eth abi function
/// \param idx index for the parameter (0-based).
/// \param isOutput determines if the parameter is an input or output
/// \return the value of the parameter.
EXPORT_API
bool TWEthereumAbiFunctionGetParamBoolNative(struct TWEthereumAbiFunction* fn,
                                             int idx, bool isOutput)
{
    return TWEthereumAbiFunctionGetParamBool(fn, idx, isOutput);
}

/// Get a string type parameter at the given index
///
/// \param fn A Non-null eth abi function
/// \param idx index for the parameter (0-based).
/// \param isOutput determines if the parameter is an input or output
/// \return the value of the parameter.
EXPORT_API
TWString*
TWEthereumAbiFunctionGetParamStringNative(struct TWEthereumAbiFunction* fn,
                                          int idx, bool isOutput)
{
    return TWEthereumAbiFunctionGetParamString(fn, idx, isOutput);
}

/// Get an address type parameter at the given index
///
/// \param fn A Non-null eth abi function
/// \param idx index for the parameter (0-based).
/// \param isOutput determines if the parameter is an input or output
/// \return the value of the parameter.
EXPORT_API
TWData*
TWEthereumAbiFunctionGetParamAddressNative(struct TWEthereumAbiFunction* fn,
                                           int idx, bool isOutput)
{
    return TWEthereumAbiFunctionGetParamAddress(fn, idx, isOutput);
}

/// Methods for adding a parameter of the given type to a top-level input parameter array.  Returns the index of the parameter (0-based).
/// Note that nested ParamArrays are not possible through this API, could be done by using index paths like "1/0"

/// Adding a uint8 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamUInt8Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, uint8_t val)
{
    return TWEthereumAbiFunctionAddInArrayParamUInt8(fn, arrayIdx, val);
}

/// Adding a uint16 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamUInt16Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, uint16_t val)
{
    return TWEthereumAbiFunctionAddInArrayParamUInt16(fn, arrayIdx, val);
}

/// Adding a uint32 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamUInt32Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, uint32_t val)
{
    return TWEthereumAbiFunctionAddInArrayParamUInt32(fn, arrayIdx, val);
}

/// Adding a uint64 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamUInt64Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, uint64_t val)
{
    return TWEthereumAbiFunctionAddInArrayParamUInt64(fn, arrayIdx, val);
}

/// Adding a uint256 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter stored in a block of data
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamUInt256Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, TWData* val)
{
    return TWEthereumAbiFunctionAddInArrayParamUInt256(fn, arrayIdx, val);
}

/// Adding a uint[N] type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param bits Number of bits of the integer parameter
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter stored in a block of data
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamUIntNNative(
    struct TWEthereumAbiFunction* fn, int arrayIdx, int bits, TWData* val)
{
    return TWEthereumAbiFunctionAddInArrayParamUIntN(fn, arrayIdx, bits, val);
}

/// Adding a int8 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamInt8Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, int8_t val)
{
    return TWEthereumAbiFunctionAddInArrayParamInt8(fn, arrayIdx, val);
}

/// Adding a int16 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamInt16Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, int16_t val)
{
    return TWEthereumAbiFunctionAddInArrayParamInt16(fn, arrayIdx, val);
}

/// Adding a int32 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamInt32Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, int32_t val)
{
    return TWEthereumAbiFunctionAddInArrayParamInt32(fn, arrayIdx, val);
}

/// Adding a int64 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamInt64Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, int64_t val)
{
    return TWEthereumAbiFunctionAddInArrayParamInt64(fn, arrayIdx, val);
}

/// Adding a int256 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter stored in a block of data
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamInt256Native(
    struct TWEthereumAbiFunction* fn, int arrayIdx, TWData* val)
{
    return TWEthereumAbiFunctionAddInArrayParamInt256(fn, arrayIdx, val);
}

/// Adding a int[N] type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param bits Number of bits of the integer parameter
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter stored in a block of data
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamIntNNative(
    struct TWEthereumAbiFunction* fn, int arrayIdx, int bits, TWData* val)
{
    return TWEthereumAbiFunctionAddInArrayParamIntN(fn, arrayIdx, bits, val);
}

/// Adding a bool type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamBoolNative(
    struct TWEthereumAbiFunction* fn, int arrayIdx, bool val)
{
    return TWEthereumAbiFunctionAddInArrayParamBool(fn, arrayIdx, val);
}

/// Adding a string type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamStringNative(
    struct TWEthereumAbiFunction* fn, int arrayIdx, TWString* val)
{
    return TWEthereumAbiFunctionAddInArrayParamString(fn, arrayIdx, val);
}

/// Adding an address type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamAddressNative(
    struct TWEthereumAbiFunction* fn, int arrayIdx, TWData* val)
{
    return TWEthereumAbiFunctionAddInArrayParamAddress(fn, arrayIdx, val);
}

/// Adding a bytes type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamBytesNative(
    struct TWEthereumAbiFunction* fn, int arrayIdx, TWData* val)
{
    return TWEthereumAbiFunctionAddInArrayParamBytes(fn, arrayIdx, val);
}

/// Adding a int64 type parameter of to the top-level input parameter array
///
/// \param fn A Non-null eth abi function
/// \param arrayIdx array index for the abi function (0-based).
/// \param size fixed size of the bytes array parameter (val).
/// \param val the value of the parameter
/// \return the index of the added parameter (0-based).
EXPORT_API
int TWEthereumAbiFunctionAddInArrayParamBytesFixNative(
    struct TWEthereumAbiFunction* fn, int arrayIdx, size_t size, TWData* val)
{
    return TWEthereumAbiFunctionAddInArrayParamBytesFix(fn, arrayIdx, size,
                                                        val);
}