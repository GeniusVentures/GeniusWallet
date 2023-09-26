#include "TWString.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/**
 * @brief       Creates a string from a null-terminated UTF8 byte array. It must be deleted at the end.
 * @param[in]   bytes Null-terminated UTF8 byte array
 * @return      Newly created TWString
 */
EXPORT_API
TWString* TWStringCreateWithUTF8BytesNative(const char* bytes)
{
    return TWStringCreateWithUTF8Bytes(bytes);
}

/**
 * @brief       Creates a string from a raw byte array and size.
 * @param[in]   bytes byte array
 * @param[in]   size size of the byte array 
 * @return      Newly created TWString
 */
EXPORT_API
TWString* TWStringCreateWithRawBytesNative(const uint8_t* bytes, size_t size)
{
    return TWStringCreateWithRawBytes(bytes, size);
}

/**
 * @brief       Creates a hexadecimal string from a block of data. It must be deleted at the end.
 * @param[in]   data Block of data
 * @return      Newly Created @ref TWString
 */
EXPORT_API
TWString* TWStringCreateWithHexDataNative(TWData* data)
{
    return TWStringCreateWithHexData(data);
}

/**
 * @brief       Returns the string size in bytes
 * @param[in]   string String to be measured
 * @return      Size of the string in bytes 
 */
EXPORT_API
size_t TWStringSizeNative(TWString* string)
{
    return TWStringSize(string);
}

/**
 * @brief       Returns the byte at the provided index.
 * @param[in]   string Input string
 * @param[in]   index Desired index of the string
 * @return      Char on the desired index of the provided string
 */
EXPORT_API
char TWStringGetNative(TWString* string, size_t index)
{
    return TWStringGet(string, index);
}

/**
 * @brief       Returns the raw pointer to the string's UTF8 bytes (null-terminated).
 * @param[in]   string Input string
 * @return      Char pointer of the input string
 */
EXPORT_API
const char* TWStringUTF8BytesNative(TWString* string)
{
    return TWStringUTF8Bytes(string);
}

/**
 * @brief           Deletes a string created with a `TWStringCreate*` method.
 * @param[in,out]   string String to be deleted
 * @warning         After delete it must not be used (can segfault)!
 */
EXPORT_API
void TWStringDeleteNative(TWString* string)
{
    TWStringDelete(string);
}

/**
 * @brief       Determines whether two string blocks are equal.
 * @param[in]   lhs First input string
 * @param[in]   rhs Second input string
 * @return      true if strings are equal, false otherwise
 */
EXPORT_API
bool TWStringEqualNative(TWString* lhs, TWString* rhs)
{
    return TWStringEqual(lhs, rhs);
}
