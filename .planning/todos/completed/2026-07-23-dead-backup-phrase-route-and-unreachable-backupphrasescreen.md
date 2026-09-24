---
created: 2026-07-23T09:32:00.000Z
title: Dead onboarding route /backup_phrase and unreachable BackupPhraseScreen
area: general
files:
  - lib/onboarding/routes/wallet_routes.dart
  - lib/onboarding/new_wallet/view/backup_phrase_screen.dart
---

## Problem

`BackupPhraseScreen` is dead code — reachable from no user flow. Verified by exhaustive grep
(UI-SPEC §5.1, re-confirmed here):

- The widget is imported by exactly one file, `wallet_routes.dart`, which registers it at
  `GoRoute(path: '/backup_phrase')`.
- **Nothing in `lib/` pushes, `go`s to, or otherwise reaches `/backup_phrase`.**
  `NewWalletFlow._buildStep`'s `NewWalletStep` switch has no case that renders it (the `agreement`
  step renders `LegalScreen`), and there is no `NewWalletStep` enum value for a distinct "backup"
  step at all.

Owner: `wallet_routes.dart` (the registration) plus `backup_phrase_screen.dart` (the orphan widget).

## Why this is filed, not fixed

Deliberately scope-fenced by Phase 6 (UI-SPEC §5.1). ROADMAP Phase 6 criterion 1 names create /
import / recovery-phrase / verify / legal "complete end to end on a fresh install" — it does not
name a backup-phrase screen, and one cannot "complete end to end" through a screen no route reaches.
So this phase did **not** re-skin it (06-02 confirmed all 8 `GoRoute`s, including this one, are
byte-identical, and `backup_phrase_screen.dart` shows zero diff across the phase — the §5 scope
fence held). Recording it here rather than leaving an undocumented orphan; a filed todo records the
gap, it does not close it.

## Solution

TBD in a future milestone — a product call, not an onboarding re-skin decision:

1. **Delete both** the `/backup_phrase` `GoRoute` registration and `backup_phrase_screen.dart`, if
   the screen is genuinely obsolete; or
2. **Wire it into the flow** — add the corresponding `NewWalletStep` value and a `_buildStep` case —
   if a post-creation "back up your phrase" step is actually wanted.

Either way, re-run the seed-safety gate (`tool/check_onboarding_seed_safety.sh`) afterward, since
wiring the screen in would bring it into the security-critical scope.

Related: UI-SPEC §5.1, §9 open question 3; 06-02-SUMMARY.md.
