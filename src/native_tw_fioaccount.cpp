#include "TWFIOAccount.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Create a FIO Account
///
/// \param string Account name
/// \note Must be deleted with \TWFIOAccountDelete
/// \return Pointer to a nullable FIO Account
EXPORT_API
struct TWFIOAccount* TWFIOAccountCreateWithStringNative(TWString* string)
{
    return TWFIOAccountCreateWithString(string);
}

/// Delete a FIO Account
///
/// \param account Pointer to a non-null FIO Account
EXPORT_API
void TWFIOAccountDeleteNative(struct TWFIOAccount* account)
{
    TWFIOAccountDelete(account);
}

/// Returns the short account string representation.
///
/// \param account Pointer to a non-null FIO Account
/// \return Account non-null string representation
EXPORT_API
TWString* TWFIOAccountDescriptionNative(struct TWFIOAccount* account)
{
    return TWFIOAccountDescription(account);
}