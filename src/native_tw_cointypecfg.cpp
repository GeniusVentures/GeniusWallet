#include "TWCoinTypeConfiguration.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Returns stock symbol of coin
///
/// \param type A coin type
/// \return A non-null TWString stock symbol of coin
/// \note Caller must free returned object
EXPORT_API
TWString* TWCoinTypeConfigurationGetSymbolNative(enum TWCoinType type)
{
    return TWCoinTypeConfigurationGetSymbol(type);
}

/// Returns max count decimal places for minimal coin unit
///
/// \param type A coin type
/// \return Returns max count decimal places for minimal coin unit
EXPORT_API
int TWCoinTypeConfigurationGetDecimalsNative(enum TWCoinType type)
{
    return TWCoinTypeConfigurationGetDecimals(type);
}

/// Returns transaction url in blockchain explorer
///
/// \param type A coin type
/// \param transactionID A transaction identifier
/// \return Returns a non-null TWString transaction url in blockchain explorer
EXPORT_API
TWString*
TWCoinTypeConfigurationGetTransactionURLNative(enum TWCoinType type,
                                               TWString*       transactionID)
{
    return TWCoinTypeConfigurationGetTransactionURL(type, transactionID);
}

/// Returns account url in blockchain explorer
///
/// \param type A coin type
/// \param accountID an Account identifier
/// \return Returns a non-null TWString account url in blockchain explorer
EXPORT_API
TWString* TWCoinTypeConfigurationGetAccountURLNative(enum TWCoinType type,
                                                     TWString* accountID)
{
    return TWCoinTypeConfigurationGetAccountURL(type, accountID);
}

/// Returns full name of coin in lower case
///
/// \param type A coin type
/// \return Returns a non-null TWString, full name of coin in lower case
EXPORT_API
TWString* TWCoinTypeConfigurationGetIDNative(enum TWCoinType type)
{
    return TWCoinTypeConfigurationGetID(type);
}

/// Returns full name of coin
///
/// \param type A coin type
/// \return Returns a non-null TWString, full name of coin
EXPORT_API
TWString* TWCoinTypeConfigurationGetNameNative(enum TWCoinType type)
{
    return TWCoinTypeConfigurationGetName(type);
}
