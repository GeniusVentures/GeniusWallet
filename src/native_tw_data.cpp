#include "TWData.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

EXPORT_API
double get_temperature(void)
{
    return 35.0;
}

/**
 * @brief Creates a block of data from a byte array.
 * 
 * @param[in] bytes Non-null raw bytes buffer 
 * @param[in] size size of the buffer
 * @return Non-null filled block of data.
 */
EXPORT_API
TWData* TWDataCreateWithBytesNative(const uint8_t* bytes, size_t size)
{
    return TWDataCreateWithBytes(bytes, size);
}

/**
 * @brief Creates an uninitialized block of data with the provided size.
 * 
 * @param[in] size size for the block of data
 * @return Non-null uninitialized block of data with the provided size
 */
EXPORT_API
TWData* TWDataCreateWithSizeNative(size_t size)
{
    return TWDataCreateWithSize(size);
}
/**
 * @brief Creates a block of data by copying another block of data.
 * 
 * @param[in] data buffer that need to be copied
 * @return Non-null filled block of data.
 */
EXPORT_API
TWData* TWDataCreateWithDataNative(TWData* data)
{
    return TWDataCreateWithData(data);
}
/**
 * @brief Creates a block of data from a hexadecimal string.  Odd length is invalid (intended grouping to bytes is not obvious).
 * 
 * @param[in] hex input hex string
 * @return Non-null filled block of data
 */
EXPORT_API
TWData* TWDataCreateWithHexStringNative(const TWString* hex)
{
    return TWDataCreateWithHexString(hex);
}

/**
 * @brief Returns the size in bytes.
 * 
 * @param[in] data A non-null valid block of data
 * @return the size of the given block of data 
 */
EXPORT_API
size_t TWDataSizeNative(TWData* data)
{
    return TWDataSize(data);
}

/**
 * @brief Returns the raw pointer to the contents of data.
 * 
 * @param[in] data A non-null valid block of data
 * @return the raw pointer to the contents of data
 */
EXPORT_API
uint8_t* TWDataBytesNative(TWData* data)
{
    return TWDataBytes(data);
}

/**
 * @brief Returns the byte at the provided index.
 * 
 * @param[in] data A non-null valid block of data
 * @param[in] index index of the byte that we want to fetch - index need to be < TWDataSize(data)
 * @return the byte at the provided index 
 */
EXPORT_API
uint8_t TWDataGetNative(TWData* data, size_t index)
{
    return TWDataGet(data, index);
}

/**
 * @brief Sets the byte at the provided index.
 * 
 * @param[in] data A non-null valid block of data
 * @param[in] index index of the byte that we want to set - index need to be < TWDataSize(data)
 * @param[in] byte Given byte to be written in data
 */
EXPORT_API
void TWDataSetNative(TWData* data, size_t index, uint8_t byte)
{
    TWDataSet(data, index, byte);
}

/**
 * @brief Copies a range of bytes into the provided buffer.
 * 
 * @param[in] data A non-null valid block of data
 * @param[in] start starting index of the range - index need to be < TWDataSize(data)
 * @param[in] size size of the range we want to copy - size need to be < TWDataSize(data) - start
 * @param[out] output The output buffer where we want to copy the data.
 */
EXPORT_API
void TWDataCopyBytesNative(TWData* data, size_t start, size_t size,
                           uint8_t* output)
{
    TWDataCopyBytes(data, start, size, output);
}

/**
 * @brief Replaces a range of bytes with the contents of the provided buffer.
 * 
 * @param[in,out] data A non-null valid block of data
 * @param[in] start starting index of the range - index need to be < TWDataSize(data)
 * @param[in] size size of the range we want to replace - size need to be < TWDataSize(data) - start
 * @param[in] bytes The buffer that will replace the range of data
 */
EXPORT_API
void TWDataReplaceBytesNative(TWData* data, size_t start, size_t size,
                              const uint8_t* bytes)
{
    TWDataReplaceBytes(data, start, size, bytes);
}

/**
 * @brief Appends data from a byte array.
 * 
 * @param[in,out] data A non-null valid block of data
 * @param[in] bytes Non-null byte array
 * @param[in] size The size of the byte array
 */
EXPORT_API
void TWDataAppendBytesNative(TWData* data, const uint8_t* bytes, size_t size)
{
    TWDataAppendBytes(data, bytes, size);
}

/**
 * @brief Appends a single byte.
 * 
 * @param[in,out] data A non-null valid block of data
 * @param[in] byte A single byte
 */
EXPORT_API
void TWDataAppendByteNative(TWData* data, uint8_t byte)
{
    TWDataAppendByte(data, byte);
}

/**
 * @brief Appends a block of data.
 * 
 * @param[in,out] data A non-null valid block of data
 * @param[in] append A non-null valid block of data
 */
EXPORT_API
void TWDataAppendDataNative(TWData* data, TWData* append)
{
    TWDataAppendData(data, append);
}

/**
 * @brief Reserve the bytes.
 * 
 * @param[in,out] data A non-null valid block of data
 */
EXPORT_API
void TWDataReverseNative(TWData* data)
{
    TWDataReverse(data);
}

/**
 * @brief Sets all bytes to the given value.
 * 
 * @param[in,out] data A non-null valid block of data
 */
EXPORT_API
void TWDataResetNative(TWData* data)
{
    TWDataReset(data);
}

/**
 * @brief Deletes a block of data created with a `TWDataCreate*` method.
 * 
 * @param[in,out] data A non-null valid block of data
 */
EXPORT_API
void TWDataDeleteNative(TWData* data)
{
    TWDataDelete(data);
}

/**
 * @brief Determines whether two data blocks are equal.
 * 
 * @param[in] lhs left non null block of data to be compared
 * @param[in] rhs right non null block of data to be compared
 * @return true if both block of data are equal, false otherwise
 */
EXPORT_API
bool TWDataEqualNative(TWData* lhs, TWData* rhs)
{
    return TWDataEqual(lhs, rhs);
}
