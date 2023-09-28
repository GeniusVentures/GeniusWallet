#include "TWNEARAccount.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Create a NEAR Account
///
/// \param string Account name
/// \note Account should be deleted by calling \TWNEARAccountDelete
/// \return Pointer to a nullable NEAR Account.
EXPORT_API
struct TWNEARAccount* TWNEARAccountCreateWithStringNative(TWString* string)
{
    return TWNEARAccountCreateWithString(string);
}

/// Delete the given Near Account
///
/// \param account Pointer to a non-null NEAR Account
EXPORT_API
void TWNEARAccountDeleteNative(struct TWNEARAccount* account)
{
    return TWNEARAccountDelete(account);
}

/// Returns the user friendly string representation.
///
/// \param account Pointer to a non-null NEAR Account
/// \return Non-null string account description
EXPORT_API
TWString* TWNEARAccountDescriptionNative(struct TWNEARAccount* account)
{
    return TWNEARAccountDescription(account);
}
