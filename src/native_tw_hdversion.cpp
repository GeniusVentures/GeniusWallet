#include "TWHDVersion.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/**
 * @brief       Determine if the HD Version is public
 * @param[in]   version HD version
 * @return      true if the version is public, false otherwise
 */
EXPORT_API
bool TWHDVersionIsPublicNative(enum TWHDVersion version)
{
    return TWHDVersionIsPublic(version);
}

/**
 * @brief       Determine if the HD Version is private
 * @param[in]   version HD version
 * @return      true if the version is private, false otherwise
 */
EXPORT_API
bool TWHDVersionIsPrivateNative(enum TWHDVersion version)
{
    return TWHDVersionIsPrivate(version);
}
