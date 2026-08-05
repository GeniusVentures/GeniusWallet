---
created: 2026-07-23T09:34:00.000Z
title: Import screen's TextEditingControllers are built per-build and never disposed, holding key material
area: security
files:
  - lib/onboarding/existing_wallet/view/import_security_screen.dart:36-46
---

## Problem

`ImportSecurityScreen` is a `StatelessWidget` that constructs its `TextEditingController`s **inside
`build()`** and never disposes them. Five of them hold key material — the four `pasteField`
controllers (Phrase mnemonic, Private Key, Keystore JSON, Address) plus the keystore
`passwordField` controller — and a sixth (`walletNameController`) holds the wallet name. Because
they are created in `build()`:

- every rebuild allocates a fresh set, so key material accumulates in undisposed controllers for the
  lifetime of the screen (no `dispose()` runs — a `StatelessWidget` has no `dispose`); and
- typed input can be **lost on any bloc-driven rebuild**, since the new controllers start empty.

The screen's own in-code comment (`import_security_screen.dart:31-35`) already flags this: *"KNOWN
DEFECT, DELIBERATELY NOT FIXED HERE (06-04 §1)."* Owner:
`lib/onboarding/existing_wallet/view/import_security_screen.dart`. **Pre-existing on develop — not
introduced by this phase.**

## Why this is filed, not fixed

The fix is a **`StatelessWidget` → `StatefulWidget` conversion** (controllers moved to fields,
constructed in `initState`, released in `dispose`) — a restructure the "re-skin, never restructure"
rule forbids, and no ROADMAP Phase 6 criterion requires it. 06-04-SUMMARY ("Not fixed here, and
why") records it left alone on purpose.

**Walk note (06-04 Task 4, 2026-07-22, dark only):** the one adjacent observation is walk **step 10,
"Live flip, typed text preserved ✅"** — typed text survived the rebuild triggered by a live
appearance flip. That is reassuring but does **not** clear this: an appearance flip and a
bloc-`emit` rebuild are different triggers, the walk did not exercise a bloc-state change mid-typing,
and it says nothing about the undisposed-lifetime leak, which is the security half. (06-06's plan
cites this as "step 8"; the typed-text observation is actually step 10 — step 8 was the loading
overlay.)

## Solution

TBD — convert `ImportSecurityScreen` to a `StatefulWidget`: hold all six controllers as state
fields, create them in `initState`, and `dispose()` every one (so key material is released
promptly). Then re-run `tool/check_onboarding_seed_safety.sh` and re-walk an import end to end
(including a bloc-driven rebuild mid-typing) to confirm typed input survives and nothing regresses.

Related: UI-SPEC §3.6; 06-04-SUMMARY.md; the sibling key-safety todo
`.planning/todos/pending/2026-07-21-seed-phrase-clipboard-has-no-expiry-or-confirm.md`.
