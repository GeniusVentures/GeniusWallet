#include "TWStellarPassphrase.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

extern "C"
{
    const char* TWStellarPassphrase_StellarNative =
        TWStellarPassphrase_Stellar;
    const char* TWStellarPassphrase_KinNative = TWStellarPassphrase_Kin;
}
