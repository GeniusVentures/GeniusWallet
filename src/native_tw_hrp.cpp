#include "TWHRP.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

//extern "C" const char *HRP_BITCOIN_NATIVE = "bc";
extern "C"
{
    const char* HRP_BITCOIN_NATIVE         = HRP_BITCOIN;
    const char* HRP_LITECOIN_NATIVE        = HRP_LITECOIN;
    const char* HRP_VIACOIN_NATIVE         = HRP_VIACOIN;
    const char* HRP_GROESTLCOIN_NATIVE     = HRP_GROESTLCOIN;
    const char* HRP_DIGIBYTE_NATIVE        = HRP_DIGIBYTE;
    const char* HRP_MONACOIN_NATIVE        = HRP_MONACOIN;
    const char* HRP_COSMOS_NATIVE          = HRP_COSMOS;
    const char* HRP_BITCOINCASH_NATIVE     = HRP_BITCOINCASH;
    const char* HRP_BITCOINGOLD_NATIVE     = HRP_BITCOINGOLD;
    const char* HRP_IOTEX_NATIVE           = HRP_IOTEX;
    const char* HRP_NERVOS_NATIVE          = HRP_NERVOS;
    const char* HRP_ZILLIQA_NATIVE         = HRP_ZILLIQA;
    const char* HRP_TERRA_NATIVE           = HRP_TERRA;
    const char* HRP_CRYPTOORG_NATIVE       = HRP_CRYPTOORG;
    const char* HRP_KAVA_NATIVE            = HRP_KAVA;
    const char* HRP_OASIS_NATIVE           = HRP_OASIS;
    const char* HRP_BLUZELLE_NATIVE        = HRP_BLUZELLE;
    const char* HRP_BAND_NATIVE            = HRP_BAND;
    const char* HRP_ELROND_NATIVE          = HRP_ELROND;
    const char* HRP_SECRET_NATIVE          = HRP_SECRET;
    const char* HRP_AGORIC_NATIVE          = HRP_AGORIC;
    const char* HRP_BINANCE_NATIVE         = HRP_BINANCE;
    const char* HRP_ECASH_NATIVE           = HRP_ECASH;
    const char* HRP_THORCHAIN_NATIVE       = HRP_THORCHAIN;
    const char* HRP_HARMONY_NATIVE         = HRP_HARMONY;
    const char* HRP_CARDANO_NATIVE         = HRP_CARDANO;
    const char* HRP_QTUM_NATIVE            = HRP_QTUM;
    const char* HRP_NATIVEINJECTIVE_NATIVE = HRP_NATIVEINJECTIVE;
    const char* HRP_OSMOSIS_NATIVE         = HRP_OSMOSIS;
    const char* HRP_TERRAV2_NATIVE         = HRP_TERRAV2;
    const char* HRP_COREUM_NATIVE          = HRP_COREUM;
    const char* HRP_NATIVECANTO_NATIVE     = HRP_NATIVECANTO;
    const char* HRP_SOMMELIER_NATIVE       = HRP_SOMMELIER;
    const char* HRP_FETCHAI_NATIVE         = HRP_FETCHAI;
    const char* HRP_MARS_NATIVE            = HRP_MARS;
    const char* HRP_UMEE_NATIVE            = HRP_UMEE;
    const char* HRP_QUASAR_NATIVE          = HRP_QUASAR;
    const char* HRP_PERSISTENCE_NATIVE     = HRP_PERSISTENCE;
    const char* HRP_AKASH_NATIVE           = HRP_AKASH;
    const char* HRP_NOBLE_NATIVE           = HRP_NOBLE;
    const char* HRP_STARGAZE_NATIVE        = HRP_STARGAZE;
    const char* HRP_NATIVEEVMOS_NATIVE     = HRP_NATIVEEVMOS;
    const char* HRP_JUNO_NATIVE            = HRP_JUNO;
    const char* HRP_STRIDE_NATIVE          = HRP_STRIDE;
    const char* HRP_AXELAR_NATIVE          = HRP_AXELAR;
    const char* HRP_CRESCENT_NATIVE        = HRP_CRESCENT;
    const char* HRP_KUJIRA_NATIVE          = HRP_KUJIRA;
    const char* HRP_COMDEX_NATIVE          = HRP_COMDEX;
    const char* HRP_NEUTRON_NATIVE         = HRP_NEUTRON;
}

/**
 * @brief       
 * @param[in]   hrp 
 * @return      A @ref EXPORT_API const* 
 */
EXPORT_API
const char* stringForHRPNative(enum TWHRP hrp)
{
    return stringForHRP(hrp);
}

/**
 * @brief       
 * @param[in]   string 
 * @return      A @ref EXPORT_API enum 
 */
EXPORT_API
enum TWHRP hrpForStringNative(const char* string)
{
    return hrpForString(string);
}
