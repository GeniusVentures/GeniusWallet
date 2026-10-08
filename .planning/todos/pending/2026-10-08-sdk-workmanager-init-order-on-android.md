---
created: 2026-10-08
title: Android SDK auto-init calls WorkManager before WorkManager has started
area: sdk
owner: SDK team (GeniusSDK Android packaging)
---

## Problem

Every Android launch logs:

    E GeniusSDKInit: Failed to auto-initialize BackgroundServiceManager
    java.lang.IllegalStateException: WorkManager is not initialized properly ...
        at ai.gnus.sdk.GeniusSDKInitProvider.onCreate

So the SDK's background earning scheduler never starts on Android.

Nobody removes `WorkManagerInitializer`: not the app manifest, not any plugin, not the SDK AAR.
The develop SDK AAR (`Android-arm64-v8a-develop-Release`) declares
`ai.gnus.sdk.GeniusSDKInitProvider` with `android:initOrder="99"`. Android runs higher
`initOrder` providers first, so the SDK provider runs before androidx.startup's provider
(order 0) has initialised WorkManager. WorkManager prints this message whenever it is used
before it is initialised.

## Fix (SDK side)

Drop `android:initOrder="99"` from `GeniusSDKInitProvider`, or move the auto-init into an
androidx.startup `Initializer` that lists `WorkManagerInitializer` in `dependencies()`.

An app-side workaround (custom Application implementing `Configuration.Provider`) was
declined: it couples the app to SDK startup internals.
