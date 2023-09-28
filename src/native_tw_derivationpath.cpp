#include "TWDerivationPath.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Creates a new DerivationPath with a purpose, coin, account, change and address.
/// Must be deleted with TWDerivationPathDelete after use.
///
/// \param purpose The purpose of the Path.
/// \param coin The coin type of the Path.
/// \param account The derivation of the Path.
/// \param change The derivation path of the Path.
/// \param address hex encoded public key.
/// \return A new DerivationPath.
EXPORT_API
struct TWDerivationPath* TWDerivationPathCreateNative(enum TWPurpose purpose,
                                                      uint32_t       coin,
                                                      uint32_t       account,
                                                      uint32_t       change,
                                                      uint32_t       address)
{
    return TWDerivationPathCreate(purpose, coin, account, change, address);
}

/// Creates a new DerivationPath with a string
///
/// \param string The string of the Path.
/// \return A new DerivationPath or null if string is invalid.
EXPORT_API
struct TWDerivationPath*
TWDerivationPathCreateWithStringNative(TWString* string)
{
    return TWDerivationPathCreateWithString(string);
}

/// Deletes a DerivationPath.
///
/// \param path DerivationPath to delete.
EXPORT_API
void TWDerivationPathDeleteNative(struct TWDerivationPath* path)
{
    TWDerivationPathDelete(path);
}

/// Returns the index component of a DerivationPath.
///
/// \param path DerivationPath to get the index of.
/// \param index The index component of the DerivationPath.
/// \return DerivationPathIndex or null if index is invalid.
EXPORT_API
struct TWDerivationPathIndex*
TWDerivationPathIndexAtNative(struct TWDerivationPath* path, uint32_t index)
{
    return TWDerivationPathIndexAt(path, index);
}

/// Returns the indices count of a DerivationPath.
///
/// \param path DerivationPath to get the indices count of.
/// \return The indices count of the DerivationPath.
EXPORT_API
uint32_t TWDerivationPathIndicesCountNative(struct TWDerivationPath* path)
{
    return TWDerivationPathIndicesCount(path);
}

/// Returns the purpose enum of a DerivationPath.
///
/// \param path DerivationPath to get the purpose of.
/// \return DerivationPathPurpose.
EXPORT_API
enum TWPurpose TWDerivationPathPurposeNative(struct TWDerivationPath* path)
{
    return TWDerivationPathPurpose(path);
}

/// Returns the coin value of a derivation path.
///
/// \param path DerivationPath to get the coin of.
/// \return The coin part of the DerivationPath.
EXPORT_API
uint32_t TWDerivationPathCoinNative(struct TWDerivationPath* path)
{
    return TWDerivationPathCoin(path);
}

/// Returns the account value of a derivation path.
///
/// \param path DerivationPath to get the account of.
/// \return the account part of a derivation path.
EXPORT_API
uint32_t TWDerivationPathAccountNative(struct TWDerivationPath* path)
{
    return TWDerivationPathAccount(path);
}

/// Returns the change value of a derivation path.
///
/// \param path DerivationPath to get the change of.
/// \return The change part of a derivation path.
EXPORT_API
uint32_t TWDerivationPathChangeNative(struct TWDerivationPath* path)
{
    return TWDerivationPathChange(path);
}

/// Returns the address value of a derivation path.
///
/// \param path DerivationPath to get the address of.
/// \return The address part of the derivation path.
EXPORT_API
uint32_t TWDerivationPathAddressNative(struct TWDerivationPath* path)
{
    return TWDerivationPathAddress(path);
}

/// Returns the string description of a derivation path.
///
/// \param path DerivationPath to get the address of.
/// \return The string description of the derivation path.
EXPORT_API
TWString* TWDerivationPathDescriptionNative(struct TWDerivationPath* path)
{
    return TWDerivationPathDescription(path);
}