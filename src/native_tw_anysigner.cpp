#include "TWAnySigner.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Signs a transaction.
EXPORT_API
TWData* TWAnySignerSignNative(TWData* input, enum TWCoinType coin)
{
    return TWAnySignerSign(input, coin);
};

/// Signs a json transaction with private key.
EXPORT_API
TWString* TWAnySignerSignJSONNative(TWString* json, TWData* key,
                                           enum TWCoinType coin)
{
    return TWAnySignerSignJSON(json, key, coin);
};

EXPORT_API
bool TWAnySignerSupportsJSONNative(enum TWCoinType coin)
{
    return TWAnySignerSupportsJSON(coin);
};

/// Plan a transaction (for UTXO chains).
EXPORT_API
TWData* TWAnySignerPlanNative(TWData* input, enum TWCoinType coin)
{
    return TWAnySignerPlan(input, coin);
};