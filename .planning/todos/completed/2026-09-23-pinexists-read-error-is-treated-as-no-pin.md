---
created: 2026-09-23T00:00:00.000Z
title: pinExists() treats a secure-storage read error as "no PIN", so onboarding offers to overwrite it
area: security
severity: major
files:
  - packages/local_secure_storage/lib/src/local_secure_storage_base.dart
  - packages/genius_api/lib/src/genius_api.dart
  - lib/bloc/app_bloc.dart
---

## Problem

`pinExists()` (`local_secure_storage_base.dart:229-236`) catches any read error and returns `false`.
`GeniusApi.userExists()` (`genius_api.dart:452`) passes that through, so
`AppBloc._onCheckIfUserExists` (`app_bloc.dart:515-531`) emits `UserStatus.nonExistent` and never
reaches its own `AppStatus.error` catch. A transient read failure (locked keychain) therefore sends
the user to onboarding, which offers to create a new PIN over the real one.

Related: `loadAccount()` calls `_secureStorage.delete(key: _accountKeyPrefix)` without `await`
(`local_secure_storage_base.dart:100`), so a delete failure is unobserved.

## Fix

Let the read error propagate out of `pinExists()` so AppBloc lands on `AppStatus.error`; await the
delete in `loadAccount()`. Add a test in `test/local_wallet_storage_test.dart` that pins the fixed
behaviour (an unreadable store throws from `pinExists()`, not `false`).
