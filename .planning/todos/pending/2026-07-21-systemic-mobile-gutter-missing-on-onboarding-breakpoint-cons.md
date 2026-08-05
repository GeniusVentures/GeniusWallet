---
created: 2026-07-21T17:46:37.483Z
title: Systemic mobile gutter missing on onboarding breakpoint-constrained screens
area: ui
severity: major
files:
  - lib/onboarding/existing_wallet/view/legal_screen.dart
  - lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart
  - lib/onboarding/existing_wallet/view/import_security_screen.dart
  - lib/screens/pin_screen.dart
  - lib/onboarding/new_wallet/view/recovery_phrase_screen.dart
  - lib/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart
  - lib/onboarding/view/wallet_creation_screen.dart
---

## RESOLVED for the two seed screens — 2026-07-22 (06-03 Task 3 walk)

This todo left an open question: the two seed screens were breakpoint-constrained but *did* have
some inset, so it said they "need a per-screen check rather than assuming either way." **The check
was done and the answer is: they needed the fix.** Their existing inset was inner-widget padding —
`EdgeInsets.all(8.0)` on the grid wrapper and `symmetric(horizontal: 4.0)` on each tile — which
never reaches the page edge. At narrow widths the content still ran against the window bezel, and
a human confirmed it live before the fix.

Both are now fixed with the standard pattern (`Padding(horizontal: space8)` outside the
`ConstrainedBox`):
- `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart` ✅
- `lib/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart` ✅

**Two path corrections:** this todo listed both files under `existing_wallet/`. They actually live
under `new_wallet/`. A grep driven by the old paths would have found nothing and wrongly concluded
they were clean.

**Lesson for the remaining four:** "has an inset somewhere in the file" is not evidence of a page
gutter. Check what the inset is attached to, not merely that one exists.

**Still open:** `legal_screen.dart` and `select_wallet_type_screen.dart` were fixed in 06-02;
`import_security_screen.dart` (06-04) and `pin_screen.dart` (06-05) remain.

## Problem

Four onboarding screens use `ConstrainedBox(maxWidth: GeniusBreakpoints.small …)` inside a `Center`
with **zero** horizontal inset. A `maxWidth` only constrains when the viewport is *wider* than it —
below that width the constraint is inert and content runs edge-to-edge against the window bezel.

Confirmed by grep at HEAD, breakpoint-constrained with **no** horizontal inset:
- `lib/onboarding/existing_wallet/view/legal_screen.dart`
- `lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart`
- `lib/onboarding/existing_wallet/view/import_security_screen.dart`
- `lib/screens/pin_screen.dart`

Two more are breakpoint-constrained but DO have some inset — `recovery_phrase_screen.dart` and
`verify_recovery_phrase_screen.dart`. **These need a per-screen check rather than assuming either
way** — the grep only proves an inset exists somewhere in the file, not that it is the page gutter.

**Already fixed, and this is the pattern to copy:** `wallet_creation_screen.dart`, commit `67e2821`
(plan 06-01, a walk-driven Rule-1 fix found by a human at narrow width). It wraps the existing
`ConstrainedBox` in `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8))` placed
**outside** the `ConstrainedBox`, so the gutter is *additive* and wide-window centring is byte-identical.
`space8` was chosen against real precedent (`submit_logs_screen.dart:212-213` uses the same
`Center → Padding → ConstrainedBox` shape; `markets_screen.dart` already uses `space8` as its page-edge
gutter), not invented.

**Why it matters now:** plans 06-02..06-05 own these screens. Applying the pattern deliberately in
each is far cheaper than rediscovering it through four more human walks — and this project has already
paid that price once today.

## Solution

For each of the four zero-inset screens (`legal_screen.dart`, `select_wallet_type_screen.dart`,
`import_security_screen.dart`, `pin_screen.dart`), wrap the existing `ConstrainedBox(maxWidth:
GeniusBreakpoints.small …)` in `Padding(EdgeInsets.symmetric(horizontal:
GeniusWalletConsts.space8))`, with the `Padding` **outside** the `ConstrainedBox` so the fix is
additive to (not a replacement for) the existing max-width centring. Verify wide-window centring is
unchanged by construction (the Padding only binds below `maxWidth + 32`).

For `recovery_phrase_screen.dart` and `verify_recovery_phrase_screen.dart`, first confirm whether the
existing inset in each file is actually the page-edge gutter or something else (e.g. inner-widget
padding that doesn't reach the full-width edge case) before deciding whether they need the same fix.

Apply deliberately during each of 06-02..06-05 as those plans touch these files, rather than
rediscovering the same defect through separate human walks.
