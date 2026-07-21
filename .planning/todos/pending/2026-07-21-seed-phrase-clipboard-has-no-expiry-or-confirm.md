---
created: 2026-07-21T00:00:00.000Z
title: Seed-phrase clipboard copies never expire and one has no confirm step
area: security
files:
  - lib/account/sdk_account_manager.dart:288-291
  - lib/onboarding/new_wallet/view/recovery_phrase_screen.dart:102-106
---

## Problem

Two places copy a wallet's full recovery phrase to the system clipboard, and **neither ever clears
it**:

- `lib/account/sdk_account_manager.dart:289` — `Clipboard.setData(ClipboardData(text: mnemonic))`,
  fired from a `MenuItemButton` labelled "Copy mnemonic". **There is no confirmation step** — one
  press of a menu item puts the seed on the clipboard.
- `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart:104` —
  `FlutterClipboard.copy(words.join(' '))` from the "Copy to clipboard" button on the
  recovery-phrase screen. This one at least sits behind a screen the user knowingly navigated to.

The seed then persists on the clipboard indefinitely — readable by any other application, and on
Windows retained in clipboard history if the user has it enabled. For a crypto wallet the recovery
phrase is the entire security boundary: whoever holds it holds the funds.

## Why this is filed separately

Verified against code 2026-07-21: **these are clipboard writes, not text inputs.** They were
originally swept up in the `AUDIT-260721-parallel-investigation.md` Q2 item alongside three
key-bearing `TextField`s, but the IME-hardening flags (`autocorrect`, `enableSuggestions`,
`enableIMEPersonalizedLearning`, `textCapitalization`) are meaningless here — there is no IME
surface on a copy action. The audit cited five locations; two of them, these two, were
misidentified as input fields.

`06-04-PLAN.md`'s amendment correctly excluded them from its scope for that reason and recorded
them in its threat register as `T-06-04-09` (accepted, out of scope). This todo exists so the
underlying exposure is not lost between a snapshot audit and a plan that deliberately declined it.

**This is a real exposure, not a paperwork artifact.** It simply belongs to a different fix than
IME hardening.

## Solution

Not yet decided — the right shape needs a product call, since both options trade security against
a user who genuinely needs the phrase in a password manager:

1. **Clear the clipboard on a timer** (30-60s) after either copy, with a visible countdown or a
   toast saying it will be cleared. Standard practice in password managers. Risk: clearing the
   clipboard out from under a user mid-paste is hostile, and on desktop the user may reasonably
   take longer than 60s.
2. **Add a confirm step to "Copy mnemonic"** in `sdk_account_manager.dart` — it currently has none,
   which makes it the sharper of the two edges. This is cheap and uncontroversial; do it regardless
   of what is decided about expiry.
3. Consider whether clipboard copy of a seed should exist at all on the SDK-account path, or
   whether that flow should require the user to transcribe.

**Verify on Windows specifically** — clipboard history (`Win+V`) is a separate retention surface
from the clipboard itself, and a timed clear does **not** evict an entry that history already
captured. If that holds, option 1 is weaker than it appears and should be documented as partial
mitigation rather than a fix.

Related: `.planning/AUDIT-260721-parallel-investigation.md` (Q2),
`.planning/phases/06-onboarding/06-04-PLAN.md` (`T-06-04-09`).
