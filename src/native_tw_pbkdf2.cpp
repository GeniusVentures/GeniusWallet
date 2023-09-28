#include "TWPBKDF2.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Derives a key from a password and a salt using PBKDF2 + Sha256.
///
/// \param password is the master password from which a derived key is generated
/// \param salt is a sequence of bits, known as a cryptographic salt
/// \param iterations is the number of iterations desired
/// \param dkLen is the desired bit-length of the derived key
/// \return the derived key data.
EXPORT_API
TWData* TWPBKDF2HmacSha256Native(TWData* password, TWData* salt,
                                 uint32_t iterations, uint32_t dkLen)
{
    return TWPBKDF2HmacSha256(password, salt, iterations, dkLen);
}

/// Derives a key from a password and a salt using PBKDF2 + Sha512.
///
/// \param password is the master password from which a derived key is generated
/// \param salt is a sequence of bits, known as a cryptographic salt
/// \param iterations is the number of iterations desired
/// \param dkLen is the desired bit-length of the derived key
/// \return the derived key data.
EXPORT_API
TWData* TWPBKDF2HmacSha512Native(TWData* password, TWData* salt,
                                 uint32_t iterations, uint32_t dkLen)
{
    return TWPBKDF2HmacSha512(password, salt, iterations, dkLen);
}