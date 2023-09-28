#include "TWDerivationPathIndex.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Creates a new Index with a value and hardened flag.
/// Must be deleted with TWDerivationPathIndexDelete after use.
///
/// \param value Index value
/// \param hardened Indicates if the Index is hardened.
/// \return A new Index.
EXPORT_API
struct TWDerivationPathIndex*
TWDerivationPathIndexCreateNative(uint32_t value, bool hardened)
{
    return TWDerivationPathIndexCreate(value, hardened);
}

/// Deletes an Index.
///
/// \param index Index to delete.
EXPORT_API
void TWDerivationPathIndexDeleteNative(struct TWDerivationPathIndex* index)
{
    TWDerivationPathIndexDelete(index);
}

/// Returns numeric value of an Index.
///
/// \param index Index to get the numeric value of.
EXPORT_API
uint32_t TWDerivationPathIndexValueNative(struct TWDerivationPathIndex* index)
{
    return TWDerivationPathIndexValue(index);
}

/// Returns hardened flag of an Index.
///
/// \param index Index to get hardened flag.
/// \return true if hardened, false otherwise.
EXPORT_API
bool TWDerivationPathIndexHardenedNative(struct TWDerivationPathIndex* index)
{
    return TWDerivationPathIndexHardened(index);
}

/// Returns the string description of a derivation path index.
///
/// \param path Index to get the address of.
/// \return The string description of the derivation path index.
EXPORT_API
TWString*
TWDerivationPathIndexDescriptionNative(struct TWDerivationPathIndex* index)
{
    return TWDerivationPathIndexDescription(index);
}
