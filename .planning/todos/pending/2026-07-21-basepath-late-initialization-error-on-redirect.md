---
created: 2026-07-21T00:00:00.000Z
title: "LateInitializationError: _basePath already initialized, thrown as GoException on router redirect"
area: general
files:
  - lib/router.dart
---

## Problem

Observed on the 2026-07-21 Windows debug run (`GW_DEV_TOOLS=true`, Flutter 3.41.9), thrown as an
**unhandled** exception during app start:

```
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception:
GoException: Exception during redirect: LateInitializationError:
Field '_basePath@2497326220' has already been initialized.
#0  RouteConfiguration._runInRouterZone.<anonymous closure>
    (package:go_router/src/configuration.dart:713:9)
```

Immediately above it in the same log, this line appears **twice**:

```
Base path directory: C:\Users\User\Documents
Base path directory: C:\Users\User\Documents
```

So a `late final` (or equivalent) `_basePath` is being assigned on **every** router redirect
rather than once at startup. The second assignment throws, go_router wraps it as a `GoException`,
and it escapes as an unhandled exception.

## Why it matters more than it looks

The app **does** continue to run — which is exactly why this has survived unnoticed. But:

- It is **unhandled**, so it reaches Sentry (the app ships Sentry) and will be generating noise in
  production crash reporting, competing with real signal.
- It fires **inside a redirect**, the one place where a throw can leave routing in an
  indeterminate state. Today the visible result is benign; a future redirect that depends on the
  redirect chain completing may not be.
- The double `Base path directory` print means the initialization work itself is running twice, so
  whatever else that path sets up is also being done twice.

**Not observed to affect the redesign** — this is very likely pre-existing on develop and
unrelated to the UI port. Confirm that before attributing it to any port phase; if it reproduces
on a clean `develop` checkout it is a develop bug and should be raised as such rather than
absorbed into this milestone.

## Solution

1. Find the `_basePath` declaration (start with `lib/router.dart` and whatever it calls to resolve
   the documents directory) and confirm whether it is `late final` assigned inside a redirect
   callback or other per-navigation code path.
2. Make initialization idempotent — guard the assignment, hoist it out of the redirect into
   one-time app startup, or make the field lazily computed (`late final X = …` initializer form,
   which evaluates once on first read) rather than imperatively assigned.
3. Verify by launching and navigating across several routes: the `Base path directory` line should
   print **exactly once**, and no `GoException` should appear in the log.
4. Check whether the double initialization has other side effects beyond the throw (duplicate
   directory creation, duplicate cache setup, duplicate listeners).

**Do not "fix" this by catching the exception** — swallowing it hides the double-initialization
rather than resolving it, and leaves the duplicated setup work in place.
