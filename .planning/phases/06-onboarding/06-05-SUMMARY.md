---
phase: 06-onboarding
plan: 05
subsystem: ui
tags: [flutter, onboarding, pin, key-safety, behavior-fix, type-guard, wcag, walked-dark-only]

# Dependency graph
requires:
  - phase: 06-onboarding
    plan: 04
    provides: "The import path this screen terminates, and the proven fresh-install recipe the walk depends on"
  - phase: 03-gw-component-library
    provides: "GWButton, GWColors extension"
provides:
  - "Re-skinned shared PinScreen — rendered FOUR times across both onboarding flows (createPin + confirmPin in each)"
  - "A working Continue button on both PIN steps — it had never functioned"
  - "The invoke-during-build defect class closed permanently by the type system, not by vigilance"
  - "'Incorrect PIN' on the appearance-aware token, correcting an AA failure UI-SPEC §4.9 would have shipped"
  - "The LAST of the four screens named by the systemic mobile-gutter todo"
affects: [06-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Tighten a callback's declared return type to `void` to make the analyzer reject `onPressed: callback(...)`. Costs one word and closes the invoke-during-build class permanently — the compiler becomes the tripwire."

key-files:
  created: []
  modified:
    - lib/screens/pin_screen.dart

key-decisions:
  - "The Continue button was FIXED, not deferred. develop shipped `onPressed: cond ? onCompleted(text) : null`, which with a dynamic return type CALLS onCompleted during build() and assigns its null return. Two consequences shipped: the button was permanently disabled in all four renders, and the flow advanced as a build-phase side effect that re-fired on every rebuild. Shipping a redesigned button that does nothing, in the flow ROADMAP criterion 1 says must complete end to end, was not an option."
  - "onCompleted retyped Function(String) -> void Function(String). PROVEN to work: reverting to develop's exact expression now produces `error - This expression has a type of 'void' so its value can't be used`. Both call sites already passed void Function(String), so it cost nothing."
  - "'Incorrect PIN' uses gw.statusError, NOT GeniusWalletColors.statusError. UI-SPEC §4.9 says to use the static while quoting two per-mode ratios — but that static is a single const #FF4D4D, roughly 3.4:1 on a near-white surface, an AA FAIL. The appearance-aware extension carries the two values §4.9 actually computed. §4.9 contradicts itself; the extension wins."
  - "The 1px PIN-row overflow below a 248px window is ACCEPTED, not fixed (decision 2026-07-22). It is caused by this plan's own page gutter, and 248px is narrower than any shipping device. Shrinking the cells was offered and declined so the PIN keeps one size everywhere. Recorded in code and here rather than left to be rediscovered."
  - "The PIN-mismatch flow (bounced back to re-enter BOTH PINs) was NOT changed. It is develop's shipped design, verified during the walk; changing it is a flow restructure, which §1 forbids. Filed as a todo instead."

requirements-completed: [SCR-02]

coverage:
  - id: D1
    description: "PinScreen re-skinned, its Continue button made functional, and the defect class closed by the type system"
    requirement: "SCR-02"
    verification:
      - kind: other
        ref: "flutter analyze — 'No issues found!' on pin_screen.dart and both verify-only call sites; analyze lib holds at the 61 baseline"
        status: pass
      - kind: other
        ref: "TYPE GUARD PROVEN: reverting the closure to develop's `onPressed: onCompleted(...)` produces use_of_void_result at pin_screen.dart:110. Tested, then restored."
        status: pass
      - kind: manual_procedural
        ref: "Walk 2026-07-22 (dark): Continue enables and ADVANCES ON PRESS; PIN cells redesigned and still masked; 'Incorrect PIN' renders in red; gutter present at narrow width; live flip re-skins everything; create-wallet completes end to end to /dashboard"
        status: pass
    human_judgment: true
    rationale: "That the button now fires on press rather than on the last keystroke is behavioural and could only be established live. Masking, error legibility and the appearance flip likewise."

duration: ~45min (1 auto task + walk)
completed: 2026-07-22
status: complete
---

# Phase 06 Plan 05: PIN screen Summary

**One file, rendered four times across both onboarding flows. Re-skinned, and a real defect fixed: the Continue button had never worked. Walked end to end to the dashboard. Plan CLOSED.**

## The defect: Continue has never worked

develop shipped this:

```dart
onPressed: state.pinFullness == PinFullness.completed
    ? onCompleted(state.pinController.text)   // a CALL, not a reference
    : null,
```

`onCompleted` was declared `Function(String)` — a **dynamic** return type — so that expression
**invokes** `onCompleted` during `build()` and assigns its return value to `onPressed`. Both call
sites pass a `void` function, so the value assigned is always `null`. Two things shipped:

1. **The Continue button was permanently disabled** — in both PIN steps, in both flows. Four renders.
2. **The flow advanced as a build-phase side effect**, the instant the PIN reached full length, and
   re-fired on every rebuild while it stayed full. On a failed confirm, `displayIncorrectPin` flips,
   the widget rebuilds, and the submission fires again.

**The bug also implemented the feature**, which is why it survived: PIN entry appeared to work,
because advancing-on-last-keystroke is a plausible-looking behaviour. Nobody had reason to press a
button that was never enabled.

Fixed by wrapping in a closure. Walk-confirmed: **Continue now enables when the PIN is complete and
the press is what advances the flow.**

### The class is closed by the compiler, not by vigilance

`onCompleted` is now `void Function(String)`. **Proven, not asserted** — reverting to develop's exact
expression produces:

```
error - This expression has a type of 'void' so its value can't be used
        lib\screens\pin_screen.dart:110 - use_of_void_result
```

Tested, then restored. Both call sites already passed `void Function(String)`, so the guard cost one
word. No future edit can silently reintroduce this.

## UI-SPEC §4.9 contradicts itself, and the spec lost

§4.9 says to colour 'Incorrect PIN' with `GeniusWalletColors.statusError`, and quotes **#D92D2D light
at 4.81:1** and **#FF4D4D dark at 5.90:1**.

But `GeniusWalletColors.statusError` is `static const Color(0xFFFF4D4D)` — **one mode-invariant
value**. Following §4.9 literally ships #FF4D4D in light mode: roughly **3.4:1** on a near-white
surface, an **AA fail**, while the contract claims 4.81:1. The two values §4.9 quotes actually live
on the appearance-aware `GWColors` extension (`gw_colors.dart:111` light, `:166` dark), which that
file's own note says is deliberate.

This plan uses `gw.statusError`, which delivers exactly the ratios §4.9 computed. Walk-confirmed
legible.

## Walk Record — 2026-07-22, DARK ONLY

| Check | Result |
|---|---|
| Continue enables on a complete PIN **and advances on press** | ✅ the defect is fixed |
| PIN cells redesigned; entry still **masked** | ✅ |
| 'Incorrect PIN' renders in red on the Create screen | ✅ |
| Page gutter at narrow width; Continue full-width on mobile | ✅ |
| Live appearance flip | ✅ everything re-skins |
| **Create-wallet END TO END → /dashboard** | ⚠️ walker reached the dashboard, but persistence is CONTRADICTED — see Unresolved |

**Console on a genuine wallet-creation run: no seed, no PIN, no state dump.** 0 `NewWalletState(`
dumps, 0 `recoveryWords`/`mnemonic` tokens, 0 bracketed word lists, 0 PIN tokens, 0 bloc transition
logging. This is stronger evidence than 06-03's scan, because a real wallet was generated here.

**Light mode NOT walked** — deferred per the 2026-07-22 backlog policy, not recorded as passing.

## ⚠️ UNRESOLVED — a created wallet may not persist

**Downgraded after the walk, before closing.** The walker reported reaching the dashboard, and that
observation stands as made. But every persistence signal, checked minutes later with the app still
running and again after shutdown, says no wallet exists:

| Signal | After this CREATE walk | After 06-04's IMPORT walk, same day |
|---|---|---|
| `SuperGNUSNode.Node.*` dirs | **0** | **1** |
| `transactions_0x*.hive` boxes | **0** | **2** |
| `flutter_secure_storage.dat` | **310 bytes** (account-only) | materially larger |

The import path, same machine, same day, through the same PIN steps, **did** persist. This one did
not. The run log also carries `No suitable wallet found` and shows no dashboard activity — though
logging here is sparse enough that absence is weak evidence alone.

**No cause has been established and none is recorded.** If it reproduces, a user can create a
wallet, complete PIN setup, see the dashboard, restart, and find nothing — with the recovery phrase
already dismissed. Filed as
`todos/pending/2026-07-22-created-wallet-may-not-persist-after-reaching-dashboard.md` with the
first three diagnostic steps.

**What this does and does not change about 06-05.** Everything this plan actually owns is verified:
the Continue button works, the type guard holds, the cells are themed and masked, the error text is
legible, the gutter landed. Those were each observed directly. What is NOT established is that the
whole create-wallet chain persists its result — which is a flow/SDK question, not a `pin_screen.dart`
question. 06-05 is closed on its own scope; criterion 1's create half is left OPEN.

## Two findings that were NOT defects

**1. A PIN mismatch bounces you back to "Create a PIN".** This looked wrong and is develop's shipped
design, verified in code during the walk: `new_wallet_flow.dart:79` dispatches `PinConfirmFailed()`
which routes back to `createPin`, and `create_pin_screen.dart`'s `BlocListener` sets
`displayIncorrectPin` so the message renders on the screen you land on. It does appear and is
legible. Changing it is a flow restructure that §1 forbids — filed as
`todos/pending/2026-07-22-pin-mismatch-bounces-user-back-to-re-enter-both-pins.md` rather than
smuggled into a re-skin.

**2. The `MaterialPinTheme` block changes colour only, never layout.** `cellSize` and `spacing` are
left at their defaults, which is exactly what a null theme resolved to — the app registers no
`materialPinTheme` extension, so both paths land on `const MaterialPinTheme()`.

## One accepted, bounded limitation

A **1px RenderFlex overflow** appears in the PIN row below a **248px** window. Traced precisely: the
row needs 216px (4×48 + 3×8) and this plan's page gutter costs 32px. **It is caused by this plan**,
and it is bounded — the smallest shipping phone is 320px logical, leaving 72px spare.

Shrinking the cells at extreme narrow was offered and **declined by decision 2026-07-22**, so the PIN
keeps one size everywhere. Recorded in `pin_screen.dart` as well as here, so nobody rediscovers it as
a mystery.

## Baselines

- `flutter analyze` — **"No issues found!"** on `pin_screen.dart` and both verify-only call sites;
  `analyze lib` holds at **61**.
- `flutter test --concurrency=1` — **222 passing / 1 failing**, the documented baseline.
- `create_pin_screen.dart` and `confirm_and_save_pin_screen.dart` are **verify-only** and were read,
  not edited — confirmed still passing `title` / `onCompleted` through unchanged.

## Next Phase Readiness

**06-06 is next — the final plan of Phase 06.** It carries the phase's closeout obligations,
including several todos this phase deferred into it:

- `PasteField.height`, still declared and unread
- The per-build `TextEditingController` construction in `import_security_screen.dart` (never
  disposed, holds key material)
- Screenshot / screen-recording protection, which Phase 06 adds **none** of and claims none

The profile was consumed by this walk's end-to-end run. Re-run
`.planning/reference/FRESH-INSTALL-RECIPE.md` — proven, one command, ~30 items.

---
*Phase: 06-onboarding*
*Completed: 2026-07-22. 1 auto task; walked dark-only; the Continue button worked for the first time.*
