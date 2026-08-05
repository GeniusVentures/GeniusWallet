---
created: 2026-07-25T12:07:07.206Z
title: Dev fault injector for the feedback/Sentry failure paths
area: ui
files:
  - lib/dev/dev_fault_injector.dart
  - lib/logs/submit_logs_screen.dart
---

## Problem

Three of the Feedback tab's six states **cannot be reached in a normal run**, so they have never
been walked:

- **No-SDK** — requires `geniusApi.isSdkInitialized == false`
- **Failed-exception** — requires `Sentry.captureFeedback` to throw
- **Failed-emptyId** — requires Sentry to return `SentryId.empty()` (payload dropped/rejected
  pre-ingestion)

`lib/dev/dev_fault_injector.dart` currently exposes **only** the Markets fault
(`DevMarketsFault` / `armMarketsFault` / `disarmMarketsFault` / `marketsFault`). There is no
feedback or Sentry hook of any kind.

Consequence, recorded in `19-VERIFICATION.md` under `uncovered_by_walk`: the 2026-07-25 phase-19
walk passed all 4 human-verification items but could only render **3 of 6** states (Ready,
Sending, Success). It also means the **error-red status line was never contrast-checked in light
mode** — it only paints in a Failed state — which leaves one pairing unmeasured against the
project's hard WCAG-AA-in-both-modes rule.

**This is the same wall Phase 05-08 hit.** Markets' error/empty branches were unwalkable because
CoinGecko was 429-rate-limited all session and the code always fell back to cached data, so a
dev fixture was built *during* the walk (`DevFaultInjector.marketsFault`, hooked at the one
function both `initState` and `_retry` call, commit `3364259`). The same pattern applies here.

## Solution

Mirror the Markets fixture:

1. Add `DevFeedbackFault { noSdk, throwOnSend, emptyEventId }` + a sticky
   `ValueNotifier<DevFeedbackFault?>` to `DevFaultInjector`.
2. Hook it at the smallest number of real decision points so the fault flows through the genuine
   branches rather than painting a fake state:
   - `noSdk` → the `!geniusApi.isSdkInitialized` reads (`submit_logs_screen.dart:170`, `:243`, `:389`)
   - `throwOnSend` → inside `_submitFeedback`'s try, before `Sentry.captureFeedback`
   - `emptyEventId` → force `_isSuccessfulSentryId` to see `SentryId.empty()`
3. Add three dev-bubble buttons under the existing Mock section.
4. Gate everything `kDebugMode && kShowDevTools`, pure insertions, as the Markets fixture was.

Then re-walk the three states **and** re-check the error-red status line for light-mode AA, and
close `uncovered_by_walk` in `19-VERIFICATION.md`.
