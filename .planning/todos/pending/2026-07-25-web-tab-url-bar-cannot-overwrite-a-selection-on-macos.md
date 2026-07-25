---
created: 2026-07-25T11:51:00.947Z
title: Web tab URL bar cannot overwrite a selection (macOS)
area: ui
files:
  - lib/web/web_view_mobile.dart
---

## Problem

In the Web tab's omnibox, typing at a **collapsed caret** works, but typing **over a
selection** is silently dropped — the keystroke does nothing and the selected text stays.
On a freshly launched app there are **zero** keyboard assertions, so nothing surfaces in
logs.

Root cause is a **WKWebView ↔ Flutter text-input conflict on the "replace selection" path**
— an engine-level issue, not app logic. It is **macOS-only**: the Windows build uses
WebView2, a different engine, so this does **not** reproduce here and needs a macOS machine
to work on or verify.

Surfaced during Phase 18 (web tab chrome). Jakub reviewed the current state and still
considers it **not fixed**.

**Two fixes already tried and FAILED — do not repeat them:**
1. Synchronous select-all on focus
2. Post-frame select-all on focus

**Current shipped state:** `_onUrlFocusChange` places a **collapsed caret at the end** (no
select-all). This removes the "the bar feels dead" symptom, but does **not** restore
select-all-to-replace. It is a mitigation, not a fix.

## Solution

Two candidate directions (neither validated):

- **(a) Clear the field on focus.** Best ergonomics for typing a fresh URL, but loses
  in-place editing of the existing URL. Cheap to try.
- **(b) Investigate the WKWebView first-responder / input-context conflict at the engine
  level.** The actual fix, but significantly deeper — likely needs a minimal repro outside
  this app to isolate whether it is a Flutter engine bug worth reporting upstream.

Requires a macOS machine. Source: `.planning/HANDOFF-session-260725-web-omnibox-markets.md`
(Phase 18, PR #214).
