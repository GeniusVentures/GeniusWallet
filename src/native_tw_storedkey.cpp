#include "TWStoredKey.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Loads a key from a file.
///
/// \param path filepath to the key as a non-null string
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return Nullptr if the key can't be load, the stored key otherwise
EXPORT_API
struct TWStoredKey* TWStoredKeyLoadNative(TWString* path)
{
    return TWStoredKeyLoad(path);
}

/// Imports a private key.
///
/// \param privateKey Non-null Block of data private key
/// \param name The name of the stored key to import as a non-null string
/// \param password Non-null block of data, password of the stored key
/// \param coin the coin type
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return Nullptr if the key can't be imported, the stored key otherwise
EXPORT_API
struct TWStoredKey* TWStoredKeyImportPrivateKeyNative(TWData*   privateKey,
                                                      TWString* name,
                                                      TWData*   password,
                                                      enum TWCoinType coin)
{
    return TWStoredKeyImportPrivateKey(privateKey, name, password, coin);
}

/// Imports a private key.
///
/// \param privateKey Non-null Block of data private key
/// \param name The name of the stored key to import as a non-null string
/// \param password Non-null block of data, password of the stored key
/// \param coin the coin type
/// \param encryption cipher encryption mode
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return Nullptr if the key can't be imported, the stored key otherwise
EXPORT_API
struct TWStoredKey* TWStoredKeyImportPrivateKeyWithEncryptionNative(
    TWData* privateKey, TWString* name, TWData* password,
    enum TWCoinType coin, enum TWStoredKeyEncryption encryption)
{
    return TWStoredKeyImportPrivateKeyWithEncryption(privateKey,name, password, coin,
                                                     encryption);
}

/// Imports an HD wallet.
///
/// \param mnemonic Non-null bip39 mnemonic
/// \param name The name of the stored key to import as a non-null string
/// \param password Non-null block of data, password of the stored key
/// \param coin the coin type
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return Nullptr if the key can't be imported, the stored key otherwise
EXPORT_API
struct TWStoredKey* TWStoredKeyImportHDWalletNative(TWString*       mnemonic,
                                                    TWString*       name,
                                                    TWData*         password,
                                                    enum TWCoinType coin)
{
    return TWStoredKeyImportHDWallet(mnemonic, name, password, coin);
}

/// Imports an HD wallet.
///
/// \param mnemonic Non-null bip39 mnemonic
/// \param name The name of the stored key to import as a non-null string
/// \param password Non-null block of data, password of the stored key
/// \param coin the coin type
/// \param encryption cipher encryption mode
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return Nullptr if the key can't be imported, the stored key otherwise
EXPORT_API
struct TWStoredKey* TWStoredKeyImportHDWalletWithEncryptionNative(
    TWString* mnemonic, TWString* name, TWData* password,
    enum TWCoinType coin, enum TWStoredKeyEncryption encryption)
{
    return TWStoredKeyImportHDWalletWithEncryption(mnemonic, name, password,
                                                   coin, encryption);
}

/// Imports a key from JSON.
///
/// \param json Json stored key import format as a non-null block of data
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return Nullptr if the key can't be imported, the stored key otherwise
EXPORT_API
struct TWStoredKey* TWStoredKeyImportJSONNative(TWData* json)
{
    return TWStoredKeyImportJSON(json);
}

/// Creates a new key, with given encryption strength level. Returned object needs to be deleted.
///
/// \param name The name of the key to be stored
/// \param password Non-null block of data, password of the stored key
/// \param encryptionLevel The level of encryption, see \TWStoredKeyEncryptionLevel
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return The stored key as a non-null pointer
EXPORT_API
struct TWStoredKey*
TWStoredKeyCreateLevelNative(TWString* name, TWData* password,
                             enum TWStoredKeyEncryptionLevel encryptionLevel)
{
    return TWStoredKeyCreateLevel(name, password, encryptionLevel);
}

/// Creates a new key, with given encryption strength level.  Returned object needs to be deleted.
///
/// \param name The name of the key to be stored
/// \param password Non-null block of data, password of the stored key
/// \param encryptionLevel The level of encryption, see \TWStoredKeyEncryptionLevel
/// \param encryption cipher encryption mode
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return The stored key as a non-null pointer
EXPORT_API
struct TWStoredKey* TWStoredKeyCreateLevelAndEncryptionNative(
    TWString* name, TWData* password,
    enum TWStoredKeyEncryptionLevel encryptionLevel,
    enum TWStoredKeyEncryption      encryption)
{
    return TWStoredKeyCreateLevelAndEncryption(name, password,
                                               encryptionLevel, encryption);
}

/// Creates a new key.
///
/// \deprecated use TWStoredKeyCreateLevel.
/// \param name The name of the key to be stored
/// \param password Non-null block of data, password of the stored key
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return The stored key as a non-null pointer
EXPORT_API struct TWStoredKey* TWStoredKeyCreateNative(TWString* name,
                                                       TWData*   password)
{
    return TWStoredKeyCreate(name, password);
}

/// Creates a new key.
///
/// \deprecated use TWStoredKeyCreateLevel.
/// \param name The name of the key to be stored
/// \param password Non-null block of data, password of the stored key
/// \param encryption cipher encryption mode
/// \note Returned object needs to be deleted with \TWStoredKeyDelete
/// \return The stored key as a non-null pointer
EXPORT_API struct TWStoredKey*
TWStoredKeyCreateEncryptionNative(TWString* name, TWData* password,
                                  enum TWStoredKeyEncryption encryption)
{
    return TWStoredKeyCreateEncryption(name, password, encryption);
}

/// Delete a stored key
///
/// \param key The key to be deleted
EXPORT_API
void TWStoredKeyDeleteNative(struct TWStoredKey* key)
{
    TWStoredKeyDelete(key);
}

/// Stored key unique identifier.
///
/// \param key Non-null pointer to a stored key
/// \note Returned object needs to be deleted with \TWStringDelete
/// \return The stored key unique identifier if it's found, null pointer otherwise.
EXPORT_API
TWString* TWStoredKeyIdentifierNative(struct TWStoredKey* key)
{
    return TWStoredKeyIdentifier(key);
}

/// Stored key namer.
///
/// \param key Non-null pointer to a stored key
/// \note Returned object needs to be deleted with \TWStringDelete
/// \return The stored key name as a non-null string pointer.
EXPORT_API
TWString* TWStoredKeyNameNative(struct TWStoredKey* key)
{
    return TWStoredKeyName(key);
}

/// Whether this key is a mnemonic phrase for a HD wallet.
///
/// \param key Non-null pointer to a stored key
/// \return true if the given stored key is a mnemonic, false otherwise
EXPORT_API
bool TWStoredKeyIsMnemonicNative(struct TWStoredKey* key)
{
    return TWStoredKeyIsMnemonic(key);
}

/// The number of accounts.
///
/// \param key Non-null pointer to a stored key
/// \return the number of accounts associated to the given stored key
EXPORT_API
size_t TWStoredKeyAccountCountNative(struct TWStoredKey* key)
{
    return TWStoredKeyAccountCount(key);
}

/// Returns the account at a given index.
///
/// \param key Non-null pointer to a stored key
/// \param index the account index to be retrieved
/// \note Returned object needs to be deleted with \TWAccountDelete
/// \return Null pointer if the associated account is not found, pointer to the account otherwise.
EXPORT_API
struct TWAccount* TWStoredKeyAccountNative(struct TWStoredKey* key,
                                           size_t              index)
{
    return TWStoredKeyAccount(key, index);
}

/// Returns the account for a specific coin, creating it if necessary.
///
/// \param key Non-null pointer to a stored key
/// \param coin The coin type
/// \param wallet The associated HD wallet, can be null.
/// \note Returned object needs to be deleted with \TWAccountDelete
/// \return Null pointer if the associated account is not found/not created, pointer to the account otherwise.
EXPORT_API
struct TWAccount* TWStoredKeyAccountForCoinNative(struct TWStoredKey* key,
                                                  enum TWCoinType     coin,
                                                  struct TWHDWallet*  wallet)
{
    return TWStoredKeyAccountForCoin(key, coin, wallet);
}

/// Returns the account for a specific coin + derivation, creating it if necessary.
///
/// \param key Non-null pointer to a stored key
/// \param coin The coin type
/// \param derivation The derivation for the given coin
/// \param wallet the associated HD wallet, can be null.
/// \note Returned object needs to be deleted with \TWAccountDelete
/// \return Null pointer if the associated account is not found/not created, pointer to the account otherwise.
EXPORT_API
struct TWAccount* TWStoredKeyAccountForCoinDerivationNative(
    struct TWStoredKey* key, enum TWCoinType coin,
    enum TWDerivation derivation, struct TWHDWallet* wallet)
{
    return TWStoredKeyAccountForCoinDerivation(key, coin, derivation, wallet);
}

/// Adds a new account, using given derivation (usually TWDerivationDefault)
/// and derivation path (usually matches path from derivation, but custom possible).
///
/// \param key Non-null pointer to a stored key
/// \param address Non-null pointer to the address of the coin for this account
/// \param coin coin type
/// \param derivation derivation of the given coin type
/// \param derivationPath HD bip44 derivation path of the given coin
/// \param publicKey Non-null public key of the given coin/address
/// \param extendedPublicKey Non-null extended public key of the given coin/address
EXPORT_API
void TWStoredKeyAddAccountDerivationNative(
    struct TWStoredKey* key, TWString* address, enum TWCoinType coin,
    enum TWDerivation derivation, TWString* derivationPath,
    TWString* publicKey, TWString* extendedPublicKey)
{
    TWStoredKeyAddAccountDerivation(key, address, coin, derivation,
                                    derivationPath, publicKey,
                                    extendedPublicKey);
}

/// Adds a new account, using given derivation path.
///
/// \deprecated Use TWStoredKeyAddAccountDerivation (with TWDerivationDefault) instead.
/// \param key Non-null pointer to a stored key
/// \param address Non-null pointer to the address of the coin for this account
/// \param coin coin type
/// \param derivationPath HD bip44 derivation path of the given coin
/// \param publicKey Non-null public key of the given coin/address
/// \param extendedPublicKey Non-null extended public key of the given coin/address
EXPORT_API
void TWStoredKeyAddAccountNative(struct TWStoredKey* key, TWString* address,
                                 enum TWCoinType coin,
                                 TWString*       derivationPath,
                                 TWString*       publicKey,
                                 TWString*       extendedPublicKey)
{
    TWStoredKeyAddAccount(key, address, coin, derivationPath, publicKey,
                          extendedPublicKey);
}

/// Remove the account for a specific coin
///
/// \param key Non-null pointer to a stored key
/// \param coin Account coin type to be removed
EXPORT_API
void TWStoredKeyRemoveAccountForCoinNative(struct TWStoredKey* key,
                                           enum TWCoinType     coin)
{
    TWStoredKeyRemoveAccountForCoin(key, coin);
}

/// Remove the account for a specific coin with the given derivation.
///
/// \param key Non-null pointer to a stored key
/// \param coin Account coin type to be removed
/// \param derivation The derivation of the given coin type
EXPORT_API
void TWStoredKeyRemoveAccountForCoinDerivationNative(
    struct TWStoredKey* key, enum TWCoinType coin,
    enum TWDerivation derivation)
{
    TWStoredKeyRemoveAccountForCoinDerivation(key, coin, derivation);
}

/// Remove the account for a specific coin with the given derivation path.
///
/// \param key Non-null pointer to a stored key
/// \param coin Account coin type to be removed
/// \param derivationPath The derivation path (bip44) of the given coin type
EXPORT_API
void TWStoredKeyRemoveAccountForCoinDerivationPathNative(
    struct TWStoredKey* key, enum TWCoinType coin, TWString* derivationPath)
{
    TWStoredKeyRemoveAccountForCoinDerivationPath(key, coin, derivationPath);
}

/// Saves the key to a file.
///
/// \param key Non-null pointer to a stored key
/// \param path Non-null string filepath where the key will be saved
/// \return true if the key was successfully stored in the given filepath file, false otherwise
EXPORT_API
bool TWStoredKeyStoreNative(struct TWStoredKey* key, TWString* path)
{
    return TWStoredKeyStore(key, path);
}

/// Decrypts the private key.
///
/// \param key Non-null pointer to a stored key
/// \param password Non-null block of data, password of the stored key
/// \return Decrypted private key as a block of data if success, null pointer otherwise
EXPORT_API
TWData* TWStoredKeyDecryptPrivateKeyNative(struct TWStoredKey* key,
                                           TWData*             password)
{
    return TWStoredKeyDecryptPrivateKey(key, password);
}

/// Decrypts the mnemonic phrase.
///
/// \param key Non-null pointer to a stored key
/// \param password Non-null block of data, password of the stored key
/// \return Bip39 decrypted mnemonic if success, null pointer otherwise
EXPORT_API
TWString* TWStoredKeyDecryptMnemonicNative(struct TWStoredKey* key,
                                           TWData*             password)
{
    return TWStoredKeyDecryptMnemonic(key, password);
}

/// Returns the private key for a specific coin.  Returned object needs to be deleted.
///
/// \param key Non-null pointer to a stored key
/// \param coin Account coin type to be queried
/// \note Returned object needs to be deleted with \TWPrivateKeyDelete
/// \return Null pointer on failure, pointer to the private key otherwise
EXPORT_API
struct TWPrivateKey* TWStoredKeyPrivateKeyNative(struct TWStoredKey* key,
                                                 enum TWCoinType     coin,
                                                 TWData*             password)
{
    return TWStoredKeyPrivateKey(key, coin, password);
}

/// Decrypts and returns the HD Wallet for mnemonic phrase keys.  Returned object needs to be deleted.
///
/// \param key Non-null pointer to a stored key
/// \param password Non-null block of data, password of the stored key
/// \note Returned object needs to be deleted with \TWHDWalletDelete
/// \return Null pointer on failure, pointer to the HDWallet otherwise
EXPORT_API
struct TWHDWallet* TWStoredKeyWalletNative(struct TWStoredKey* key,
                                           TWData*             password)
{
    return TWStoredKeyWallet(key, password);
}

/// Exports the key as JSON
///
/// \param key Non-null pointer to a stored key
/// \return Null pointer on failure, pointer to a block of data containing the json otherwise
EXPORT_API
TWData* TWStoredKeyExportJSONNative(struct TWStoredKey* key)
{
    return TWStoredKeyExportJSON(key);
}

/// Fills in empty and invalid addresses.
/// This method needs the encryption password to re-derive addresses from private keys.
///
/// \param key Non-null pointer to a stored key
/// \param password Non-null block of data, password of the stored key
/// \return `false` if the password is incorrect, true otherwise.
EXPORT_API
bool TWStoredKeyFixAddressesNative(struct TWStoredKey* key, TWData* password)
{
    return TWStoredKeyFixAddresses(key, password);
}

/// Retrieve stored key encoding parameters, as JSON string.
///
/// \param key Non-null pointer to a stored key
/// \return Null pointer on failure, encoding parameter as a json string otherwise.
EXPORT_API
TWString* TWStoredKeyEncryptionParametersNative(struct TWStoredKey* key)
{
    return TWStoredKeyEncryptionParameters(key);
}
