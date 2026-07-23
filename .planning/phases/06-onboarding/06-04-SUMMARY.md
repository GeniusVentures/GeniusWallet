---
phase: 06-onboarding
plan: 04
subsystem: ui
tags: [flutter, onboarding, import, key-safety, ime-hardening, gw_text_field, gw_button, responsive, walked-dark-only]

# Dependency graph
requires:
  - phase: 06-onboarding
    plan: 03
    provides: "The walk discipline of scanning the run log as well as the screen, and the discrete-breakpoint responsive pattern"
  - phase: 03-gw-component-library
    provides: "GWButton, GWTextField, GWDecorations.surfaceSheen, GWColors extension"
provides:
  - "IME hardening on ALL key-bearing typed inputs in the app — paste_field.dart, both sdk_account_manager.dart dialogs, and (beyond plan scope, by explicit decision) the keystore password field"
  - "GWTextField extended with autocorrect / enableSuggestions / enableIMEPersonalizedLearning / textCapitalization as additive opt-ins defaulting to Flutter's stock values"
  - "Re-skinned PasteField — surfaceSheen container, token typography, GWButton paste action, brandPrimary cursor — with the clipboard handler and constructor signature untouched"
  - "Re-skinned import_security_screen.dart — GWTextField name field, gradient Import, token'd loading overlay with a real modal scrim — with the whole import dispatch byte-identical"
  - "Import path made usable on mobile: page gutter, reachable tabs, scrim"
affects: [06-05, 06-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Additive opt-in parameters on a shared primitive: GWTextField's four IME params default to Flutter's own TextFormField stock values, so every pre-existing caller is byte-identical in behaviour and only key-bearing call sites opt in."
    - "ScrollConfiguration + dragDevices including PointerDeviceKind.mouse as the fix for any horizontally-scrollable widget on desktop — Flutter's default MaterialScrollBehavior omits the mouse, so horizontal scroll areas are unreachable with a mouse and a wheel only scrolls vertically."
    - "GeniusWalletColors.surfaceOverlay as the scrim for a hand-rolled modal, matching GWDialog's and GWBottomSheet's barrierColor rather than inventing a value."

key-files:
  created: []
  modified:
    - lib/onboarding/widgets/paste_field.dart
    - lib/components/inputs/gw_text_field.dart
    - lib/account/sdk_account_manager.dart
    - lib/onboarding/existing_wallet/view/import_security_screen.dart
    - .planning/reference/FRESH-INSTALL-RECIPE.md

key-decisions:
  - "A FOURTH key-bearing field was hardened beyond the plan's written scope, by explicit decision 2026-07-22: KeystoreTabView's password field. The plan hardened three. obscureText MAY already suppress some of this on some platforms, but 'probably covered' is exactly the reasoning this plan's own amendment existed to kill — autocorrect and enableSuggestions also looked sufficient and left IME_FLAG_NO_PERSONALIZED_LEARNING open. Set explicitly so the guarantee does not rest on unverified platform behaviour."
  - "TabBar changed despite the plan saying leave it alone (Rule-1 deviation). With tabAlignment.center + isScrollable, overflowing tabs could not be reached at narrow width — TWO OF FOUR IMPORT METHODS were unreachable on a phone-sized window. A functional defect outranks 'do not touch the TabBar'."
  - "The static spinner during import is NOT a defect of this screen and was deliberately not 'fixed' here. It is the measured ~9.6s main-isolate freeze in GeniusSDKInitWithMnemonic (Phase 13, spike 001 INVALIDATED any Dart-side fix). Recorded and routed to Phase 13, whose 13-04 is unstarted."
  - "Runtime IME evidence recorded as CORROBORATING, NOT CONCLUSIVE. Nothing was recalled and no autocorrect appeared — but Windows may have no observable IME behaviour to begin with, so 'nothing happened' is consistent with both 'the flags worked' and 'there was never anything to see'. The load-bearing flag targets Android."
  - "The systemic gutter fix was applied proactively to import_security_screen.dart rather than waiting for the walk to rediscover it a fourth time."

requirements-completed: [SCR-02]

coverage:
  - id: D1
    description: "IME hardening across every key-bearing typed input in the app"
    requirement: "SCR-02"
    verification:
      - kind: other
        ref: "app-wide census: 4 hardened call sites carry all four flags; grep for the four flags across lib/ was 0 matches before this plan"
        status: pass
      - kind: other
        ref: "GWTextField defaults match Flutter's TextFormField stock exactly (true/true/true/sentences), so no pre-existing caller changes behaviour"
        status: pass
      - kind: manual_procedural
        ref: "Walk steps 4, 5, 6 — no autocorrect/suggestions on the paste fields or either SDK dialog; the learning-store recall test returned nothing"
        status: pass
    human_judgment: true
    rationale: "See the CORROBORATING-NOT-CONCLUSIVE decision above. The flags are grep-proven in source and correct per Flutter's API; the runtime observation supports but does not prove them on this platform."
  - id: D2
    description: "PasteField and import_security_screen.dart re-skinned with the import dispatch, validators, strings and failure surfaces preserved"
    requirement: "SCR-02"
    verification:
      - kind: other
        ref: "flutter analyze — 'No issues found!' on all four files individually; analyze lib holds at the 61 baseline"
        status: pass
      - kind: other
        ref: "plan verify gates: WalletSecurityEntered/getSecurityTypeFromTab/obscureText:true/both preserved strings/4 Tab labels/4 PasteField call sites/canonical Loading import — all present"
        status: pass
      - kind: manual_procedural
        ref: "Walk steps 1,2,3,7,8,9,10 PASS including end-to-end import to /dashboard"
        status: pass
    human_judgment: true
    rationale: "Import succeeding end to end, the validation gate surfacing its message, and both failure surfaces firing are behavioural and were each exercised live."

duration: ~1.5h (3 auto tasks + walk with 5 walk-driven fixes)
completed: 2026-07-22
status: complete
---

# Phase 06 Plan 04: Import path + IME hardening Summary

**All three auto tasks landed, the walk passed 10 of 11 steps (11 deferred), and five defects were found BY the walk and fixed during it. Plan CLOSED.**

The plan needed **no amendment** — it was already amended 2026-07-21. A "must amend 06-04 first" claim circulated in STATE and two SUMMARYs earlier on 2026-07-22; it was wrong, and was retracted in commit `e0b5bf3` before execution began.

## The security work

`grep` for the four IME flags across `lib/` returned **0 matches** before this plan. There was no IME hardening anywhere in the app. There are now **four hardened call sites**:

| Field | File | Why |
|---|---|---|
| Import paste box (serves all four tabs) | `paste_field.dart` | mnemonic / private key / keystore JSON |
| "Add Account with Mnemonic" | `sdk_account_manager.dart` | mnemonic |
| "Add Account with Private Key" | `sdk_account_manager.dart` | private key |
| **Keystore password** | `import_security_screen.dart` | **the fourth field — beyond plan scope, by explicit decision** |

`enableIMEPersonalizedLearning` is the load-bearing flag: it maps to Android's
`IME_FLAG_NO_PERSONALIZED_LEARNING`, the actual switch on the keyboard's learning store. The other
three produce the *appearance* of hardening while leaving that store open.

### The census is complete, and provably so

Deliberately excluded, each checked rather than assumed:

- `sdk_account_manager.dart:512` "Set Payout Address" — a **public** address, not secret.
- The wallet-name field — not key material.
- The "Copy mnemonic" `MenuItemButton` and `recovery_phrase_screen.dart`'s copy button — clipboard
  **writes** of already-known material; there is no `TextFormField` for a flag to attach to.
- **All three PIN screens** — they contain **zero text inputs**. PIN entry uses a custom on-screen
  keypad, so no IME surface exists. This looked like an obvious gap and is not one.

### What the runtime check does and does not prove

Walk steps 4–6 found no autocorrect, no suggestion strip, no auto-capitalisation, and — the real
test — **no recall of a previously-typed mnemonic word**. That is the leak the other three flags do
not close.

**Recorded as corroborating, not conclusive.** Windows may have no observable IME behaviour to begin
with, so "nothing happened" is consistent with both *the flags worked* and *there was never anything
to see*. The flags are grep-proven in source and correct per Flutter's API. A genuine confirmation
needs an Android device.

## Task 4 Walk Record — 2026-07-22, DARK ONLY

| Step | Result |
|---|---|
| 1 Empty/first-arrival, default + narrow | ✅ after the gutter fix |
| 2 All four tabs, Paste button pastes | ✅ after two tab fixes |
| 3 Keystore password still masked | ✅ |
| 4 IME on both paste fields | ✅ |
| 5 IME on both SDK dialogs | ✅ |
| 6 **Learning-store recall** | ✅ nothing recalled |
| 7 Empty-name validation + failure snackbar | ✅ both |
| 8 Loading overlay | ✅ appears + scrim; **spinner static — see below** |
| 9 **End-to-end import → dashboard** | ✅ |
| 10 Live flip, typed text preserved | ✅ |
| 11 Light mode | **deferred**, per the 2026-07-22 backlog policy — not walked, not recorded as passing |

Console across the walk: **0 exceptions, 0 overflows, 0 scroll assertions, and no key material
reaching the log** (0 `ExistingWalletState` dumps, 0 mnemonic/privateKey/pasteFieldText tokens, 0
bloc transition logging).

## Five walk-driven fixes

| # | Defect | Fix |
|---|---|---|
| 1 | No page gutter — content ran to the window bezel | `Padding(horizontal: space8)` outside the `ConstrainedBox`, applied **proactively** |
| 2 | Overflowing tabs unreachable at narrow width | `tabAlignment: isNarrow ? start : center` |
| 3 | **Tabs still unreachable — mouse could not drag them** | `ScrollConfiguration` with `PointerDeviceKind.mouse` in `dragDevices` |
| 4 | Fourth key-bearing field unhardened | All four flags on the keystore password |
| 5 | Loading overlay had no scrim, didn't read as modal | `GeniusWalletColors.surfaceOverlay`, the token `GWDialog`/`GWBottomSheet` already use |

**Fixes 2 and 3 are one defect that needed two fixes**, and that is worth remembering. `TabAlignment.start` corrected the layout, and the tabs were *still* unreachable — because Flutter's default `MaterialScrollBehavior` **omits `PointerDeviceKind.mouse` from `dragDevices` on desktop**, while a wheel only scrolls vertically. A horizontally-scrollable widget is therefore scrollable in principle and unreachable in practice on desktop. **This almost certainly affects other horizontal scroll areas in this app** — worth a sweep.

Until fix 3, **two of the four ways to import a wallet were unreachable on a phone-sized window.** That is a functional defect, not styling, which is why the plan's "leave the TabBar alone" instruction was overridden.

## Not fixed here, and why

**The import spinner does not animate.** It paints once and freezes for ~10 seconds. This is NOT a
defect of this screen: it is the measured **~9.6s main-isolate freeze during
`GeniusSDKInitWithMnemonic`** recorded by Phase 13 — *"Nothing can animate before it lifts"* — and
spike 001 INVALIDATED any Dart-side fix. Found here from a completely different direction than
session B found it, which corroborates it. **Phase 13 owns it and 13-04 is unstarted.**

Also left alone, as the plan requires: the per-build `TextEditingController` construction (they are
never disposed and hold key material — fixing it is a StatelessWidget→StatefulWidget restructure),
and `PasteField.height`, still declared and still unread.

## Corrections to FRESH-INSTALL-RECIPE.md, both found by USING it

1. **`wallet.hive` is not a freshness signal.** After a successful end-to-end import, it stayed at
   **0 bytes** while the node-directory count went 0 → 1. The doc had called it *strong*. Trusting
   it would let someone run a "fresh install" walk on a profile that already has a wallet, silently
   invalidating the walk. **Count `SuperGNUSNode.Node.*` instead.**
2. **The `*.hive` glob is load-bearing.** Importing creates per-wallet boxes named after the
   address — `transactions_0x9858…eda94.hive`. A hand-written list of "wallet, preferences, network,
   caches" would miss them and leave wallet state behind. That is a plausible explanation for at
   least one of the four failed attempts on 2026-07-21 that made this problem look intractable.

The recipe was then **executed end to end for the first time**: 32 items removed, profile returned
to `node dirs = 0`, `hive boxes = 0`, secure store gone, and the app relaunched cleanly into
onboarding. It works.

Side observation, filed not fixed: the wallet **address is exposed as a filename** under
`Documents\`. Not key material, but it leaks which addresses this machine has held.

## Baselines

- `flutter analyze` — **"No issues found!"** on all four touched files individually; `analyze lib`
  holds at the **61** baseline.
- `flutter test --concurrency=1` — **222 passing / 1 failing**, the documented baseline. The failure
  is the pre-existing, entirely-commented-out `local_wallet_storage_test.dart`.
- `verify_additive_boundary.sh` Check 2 fails on `_Section` and `_SplashState` — **proven
  pre-existing** by re-running the guard with all of this plan's changes stashed. Neither name is in
  a file this plan touched.

## Next Phase Readiness

**06-05 is next.** It owns `pin_screen.dart`, which still carries the systemic gutter defect — apply
the pattern proactively rather than rediscovering it in a fifth walk.

The wallet-less profile is available: the recipe was run after the end-to-end import, and the
profile was re-consumed by the scrim re-check, so **run step 0 of the recipe before relying on it**
and re-run the deletion if needed. It is now a proven, one-command operation.

---
*Phase: 06-onboarding*
*Completed: 2026-07-22. 3 auto tasks; Task 4 walked dark-only, 10/11 steps PASS (11 deferred), 5 walk-driven fixes landed during the walk.*
