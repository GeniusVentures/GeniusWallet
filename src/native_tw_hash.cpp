#include "TWHash.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

extern "C"
{
    const size_t TWHashSHA1LengthNative   = TWHashSHA1Length;
    const size_t TWHashSHA256LengthNative = TWHashSHA256Length;
    const size_t TWHashSHA512LengthNative = TWHashSHA512Length;
    const size_t TWHashRipemdLengthNative = TWHashRipemdLength;
}

/// Computes the SHA1 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed SHA1 block of data
EXPORT_API
TWData* TWHashSHA1Native(TWData* data)
{
    return TWHashSHA1(data);
}

/// Computes the SHA256 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed SHA256 block of data
EXPORT_API
TWData* TWHashSHA256Native(TWData* data)
{
    return TWHashSHA256(data);
}

/// Computes the SHA512 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed SHA512 block of data
EXPORT_API
TWData* TWHashSHA512Native(TWData* data)
{
    return TWHashSHA512(data);
}

/// Computes the SHA512_256 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed SHA512_256 block of data
EXPORT_API
TWData* TWHashSHA512_256Native(TWData* data)
{
    return TWHashSHA512_256(data);
}

/// Computes the Keccak256 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed Keccak256 block of data
EXPORT_API
TWData* TWHashKeccak256Native(TWData* data)
{
    return TWHashKeccak256(data);
}

/// Computes the Keccak512 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed Keccak512 block of data
EXPORT_API
TWData* TWHashKeccak512Native(TWData* data)
{
    return TWHashKeccak512(data);
}

/// Computes the SHA3_256 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed SHA3_256 block of data
EXPORT_API
TWData* TWHashSHA3_256Native(TWData* data)
{
    return TWHashSHA3_256(data);
}

/// Computes the SHA3_512 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed SHA3_512 block of data
EXPORT_API
TWData* TWHashSHA3_512Native(TWData* data)
{
    return TWHashSHA3_512(data);
}

/// Computes the RIPEMD of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed RIPEMD block of data
EXPORT_API
TWData* TWHashRIPEMDNative(TWData* data)
{
    return TWHashRIPEMD(data);
}

/// Computes the Blake256 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed Blake256 block of data
EXPORT_API
TWData* TWHashBlake256Native(TWData* data)
{
    return TWHashBlake256(data);
}

/// Computes the Blake2b of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed Blake2b block of data
EXPORT_API
TWData* TWHashBlake2bNative(TWData* data, size_t size)
{
    return TWHashBlake2b(data, size);
}

/// Computes the Groestl512 of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed Groestl512 block of data
EXPORT_API
TWData* TWHashGroestl512Native(TWData* data)
{
    return TWHashGroestl512(data);
}

/// Computes the SHA256D of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed SHA256D block of data
EXPORT_API
TWData* TWHashSHA256SHA256Native(TWData* data)
{
    return TWHashSHA256SHA256(data);
}

/// Computes the SHA256RIPEMD of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed SHA256RIPEMD block of data
EXPORT_API
TWData* TWHashSHA256RIPEMDNative(TWData* data)
{
    return TWHashSHA256RIPEMD(data);
}

/// Computes the SHA3_256RIPEMD of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed SHA3_256RIPEMD block of data
EXPORT_API
TWData* TWHashSHA3_256RIPEMDNative(TWData* data)
{
    return TWHashSHA3_256RIPEMD(data);
}

/// Computes the Blake256D of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed Blake256D block of data
EXPORT_API
TWData* TWHashBlake256Blake256Native(TWData* data)
{
    return TWHashBlake256Blake256(data);
}

/// Computes the Blake256RIPEMD of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed Blake256RIPEMD block of data
EXPORT_API
TWData* TWHashBlake256RIPEMDNative(TWData* data)
{
    return TWHashBlake256RIPEMD(data);
}

/// Computes the Groestl512D of a block of data.
///
/// \param data Non-null block of data
/// \return Non-null computed Groestl512D block of data
EXPORT_API
TWData* TWHashGroestl512Groestl512Native(TWData* data)
{
    return TWHashGroestl512Groestl512(data);
}