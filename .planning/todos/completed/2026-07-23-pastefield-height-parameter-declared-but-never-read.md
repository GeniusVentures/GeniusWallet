---
created: 2026-07-23T09:33:00.000Z
title: PasteField.height is declared, defaulted and passed but never read
area: ui
files:
  - lib/onboarding/widgets/paste_field.dart:22-31
  - lib/onboarding/existing_wallet/view/import_security_screen.dart:173
---

## Problem

`PasteField` declares a `final double height` parameter (default `200`), but nothing in its `build`
ever reads it — the field container's size comes from the `TextFormField`'s `minLines: 4` /
`maxLines: 10`, not from `height`. The Address tab passes `height: 150`
(`import_security_screen.dart:173`) and it has **no effect**. The in-code comment on the parameter
(`paste_field.dart:16-21`) already says so: *"DECLARED BUT DELIBERATELY UNREAD."*

Owner: `lib/onboarding/widgets/paste_field.dart`.

## Why this is filed, not fixed

06-04 deliberately left it inert. Wiring `height` into the newly-adopted container decoration would
be a **layout change smuggled in under a re-skin** — 06-04 adopted the reference's
`Container(decoration: …)` wholesale but did not start honouring a dimension the shipped code had
never honoured, because newly honouring it would move layout. 06-04-SUMMARY ("Not fixed here, and
why") records it left alone on purpose, alongside the undisposed-controllers item. No ROADMAP
criterion requires it.

## Solution

TBD — a small cleanup, decide which way:

1. **Delete the parameter** and its one call-site argument (`height: 150` on the Address tab), since
   nothing depends on its value; or
2. **Wire it** into the container's height if a per-tab field height is actually wanted — but treat
   that as a deliberate layout change with its own walk, not a silent re-skin follow-on.

Related: UI-SPEC §4.7; 06-04-SUMMARY.md.
