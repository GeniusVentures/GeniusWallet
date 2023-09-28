#include "TWAES.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Encrypts a block of Data using AES in Cipher Block Chaining (CBC) mode.
///
/// \param key encryption key Data, must be 16, 24, or 32 bytes long.
/// \param data Data to encrypt.
/// \param iv initialization vector.
/// \param mode padding mode.
/// \return encrypted Data.
EXPORT_API
TWData* TWAESEncryptCBCNative(TWData* key, TWData* data, TWData* iv,
                              enum TWAESPaddingMode mode)
{
    return TWAESEncryptCBC(key, data, iv, mode);
}

/// Decrypts a block of data using AES in Cipher Block Chaining (CBC) mode.
///
/// \param key decryption key Data, must be 16, 24, or 32 bytes long.
/// \param data Data to decrypt.
/// \param iv initialization vector Data.
/// \param mode padding mode.
/// \return decrypted Data.
EXPORT_API
TWData* TWAESDecryptCBCNative(TWData* key, TWData* data, TWData* iv,
                              enum TWAESPaddingMode mode)
{
    return TWAESDecryptCBC(key, data, iv, mode);
}

/// Encrypts a block of data using AES in Counter (CTR) mode.
///
/// \param key encryption key Data, must be 16, 24, or 32 bytes long.
/// \param data Data to encrypt.
/// \param iv initialization vector Data.
/// \return encrypted Data.
EXPORT_API
TWData* TWAESEncryptCTRNative(TWData* key, TWData* data, TWData* iv)
{
    return TWAESEncryptCTR(key, data, iv);
}

/// Decrypts a block of data using AES in Counter (CTR) mode.
///
/// \param key decryption key Data, must be 16, 24, or 32 bytes long.
/// \param data Data to decrypt.
/// \param iv initialization vector Data.
/// \return decrypted Data.
EXPORT_API
TWData* TWAESDecryptCTRNative(TWData* key, TWData* data, TWData* iv)
{
    return TWAESDecryptCTR(key, data, iv);
}