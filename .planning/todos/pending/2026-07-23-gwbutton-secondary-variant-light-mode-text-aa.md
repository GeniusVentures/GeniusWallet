---
created: 2026-07-23T09:30:00.000Z
title: GWButtonVariant.secondary as text in light mode — walk it, don't assume 1.93:1
area: ui
files:
  - lib/components/buttons/gw_button.dart:127-138
---

## Problem

`GWButtonVariant.secondary` renders its label as *text* on a transparent fill (effectively on
whatever surface sits behind it). Phase 6's onboarding surface leans on it three times — "I already
have a wallet" (landing, 06-01), and "Privacy Policy" / "Terms of Service" (legal, 06-02) — and it
is a shared primitive used well beyond onboarding (Settings, the SDK manager, the dashboard). The
owner is `gw_button.dart`, **not** onboarding: onboarding only consumes the variant.

## Why this is filed against gw_button.dart, and what is actually still open

06-06's plan (must-have truth #3, Task 2 item #1) describes this as an **unfixed, inherited WCAG AA
failure — raw `brandPrimaryStrong` #0AAEE6 at 1.93:1 on light `surfaceBase`.** That figure is
**stale at HEAD and must not be re-filed as current.** Walked / code evidence:

- **06-01 SUMMARY (Decisions Made; Task 3 walk item 5):** quick task `260721-fa7`, landed the same
  day *before* 06-01 ran, already repointed `gw_button.dart`'s `secondary` foreground from
  `GeniusWalletColors.brandPrimaryStrong` to the appearance-aware
  `GeniusWalletColors.brandPrimaryOnSurface` (light `#0A6885`, code-comment-measured **4.76:1** on
  `surfaceBase` — passes the 4.5:1 AA text floor; dark unchanged). Verified again here at HEAD:
  `gw_button.dart:136,138` read `brandPrimaryOnSurface`, with an in-code comment noting it replaced
  "a raw brandPrimaryStrong that missed AA against light's surfaceBase."
- So the **code-level** 1.93:1 failure the plan describes is already closed by unrelated work; this
  todo deliberately does NOT restate it as live.

**What is genuinely still open:** the *live light-mode WALK* of these three onboarding secondary
buttons was never performed. 06-01 re-verified the fix against code; **06-02 walked dark only** and
explicitly recorded (SUMMARY, "Light mode was deferred") that its item 9 — re-verifying the
inherited secondary-variant light-mode contrast — **was NOT performed and is not recorded as
passing.** That live confirmation belongs to the dedicated light-mode pass against `gw_button.dart`,
not to any onboarding plan, and is already tracked.

## Solution

No new code fix is implied — the token was already repointed. The remaining work is **verification,
not remediation**: during the single dedicated light-mode pass, live-walk `GWButtonVariant.secondary`
labels (these three onboarding buttons among them) in light mode and confirm ≥ 4.5:1 in situ per the
project WCAG contrast rule ([[wcag-contrast-rule]]). If the in-situ measurement diverges from the
4.76:1 the code comment claims, reopen against `gw_button.dart`.

Related: `.planning/todos/pending/2026-07-22-light-mode-verification-backlog.md` (its item 4 is
exactly these two legal-screen secondary link buttons); 06-01-SUMMARY.md, 06-02-SUMMARY.md.
