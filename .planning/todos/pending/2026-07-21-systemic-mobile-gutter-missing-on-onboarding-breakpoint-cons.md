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
  - lib/onboarding/existing_wallet/view/recovery_phrase_screen.dart
  - lib/onboarding/existing_wallet/view/verify_recovery_phrase_screen.dart
  - lib/onboarding/view/wallet_creation_screen.dart
---

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
