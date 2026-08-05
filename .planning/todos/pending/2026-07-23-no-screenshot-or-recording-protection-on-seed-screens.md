---
created: 2026-07-23T09:31:00.000Z
title: No screenshot / screen-recording protection on the seed screens
area: security
files:
  - lib/main.dart
  - lib/onboarding/new_wallet/view/recovery_phrase_screen.dart
  - lib/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart
---

## Problem

The recovery-phrase and verify screens render the 12-word seed **in the clear** whenever the phrase
is visible — which is the default state (`_isVisible = true`, preserved per UI-SPEC §3.2). develop
has **no** secure-window flag anywhere: no `flutter_windowmanager`-style `FLAG_SECURE`, no Windows
`SetWindowDisplayAffinity`/`WDA_MONITOR` equivalent, no platform-channel screenshot block. Verified
by grep across `lib/onboarding/**` and the app's `main.dart` / platform setup — none found (UI-SPEC
§3.5 records the same verification). So any OS-level screenshot tool, screen recorder, or
remote-desktop session captures the seed while it is on screen.

**The owner is the platform layer / `main.dart`, not onboarding.** A secure-window flag is a
window/platform capability, not a per-screen widget concern; the seed screens are listed only as the
surfaces where the exposure is observable.

## Why this is filed, not fixed

Phase 6 was a **re-skin**. It neither adds nor removes this exposure — it is develop's existing
posture, unchanged. Adding screenshot/recording protection is a **new capability**, not a re-skin,
so it is out of this phase's scope per the "re-skin, never restructure" rule, and **no ROADMAP Phase
6 criterion names it.** Recorded explicitly here so the absence is on the record rather than implied
away: **the current design assumes NO screenshot/recording protection.** This todo exists so a
future reader sees a deliberate, documented gap instead of inheriting an unstated assumption of
safety the code does not provide.

## Solution

TBD — a product/security call for a future milestone, not decided here. If pursued: gate a
secure-window flag ON while any seed-bearing screen (recovery phrase, verify, and the SDK "Copy
mnemonic" path) is mounted, and OFF elsewhere, on each desktop/mobile platform that supports one.
Note that Windows' `WDA_EXCLUDEFROMCAPTURE` blocks the app's own frames from capture but does not
defend against an external camera, and that behaviour differs per OS — document what each platform
actually guarantees rather than claiming blanket protection.

Related: UI-SPEC §3.5; `.planning/todos/pending/2026-07-21-seed-phrase-clipboard-has-no-expiry-or-confirm.md`
(the adjacent clipboard-retention exposure on the same screens).
