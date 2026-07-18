---
created: 2026-07-18T15:34:02.876Z
title: SDK account manager UX polish — add-dialog validation + drawer loading state
area: ui
files:
  - lib/account/sdk_account_manager.dart
---

## Problem

User feedback during the 04-06 SDK account manager walk (2026-07-18). The re-skin
is correct; these are deferred UX improvements (not regressions):

1. **Add-account dialog validation.** In the "Add with mnemonic" and "Add with
   private key" dialogs you can leave the field empty/null and still press the
   confirm button — it accepts an invalid/empty value. The confirm button should
   be **disabled until a valid method is entered** (non-empty / valid mnemonic or
   private key). (Same idea likely applies to the set-payout-address dialog and,
   for consistency, the rename dialog in account_dropdown_selector.)
2. **Drawer loading state.** The SDK account manager drawer has a noticeable load
   time before content appears. Add a **loading indicator/state** in the drawer
   (e.g. GWSpinner / GWLoadingState) while it loads, so it doesn't look empty/
   frozen during the wait.

## Solution

TBD — small UX pass on `sdk_account_manager.dart`:
- Gate each add-dialog's confirm GWButton `onPressed` on a validity check of the
  controller text (disable / `onPressed: null` until valid); ideally live-validate
  as the user types. Keep the key `TextEditingController` value untouched by any
  styling (security constraint from 04-06).
- Show a loading state (GWSpinner / GWLoadingState) in the drawer body while the
  account list / SDK data is loading, replaced by the rows once ready.
Keep tokens/WCAG intact ([[wcag-contrast-rule]]). Relates to the other drawer/row
UX polish todos ([[account-row-ux-polish]], [[drawer-dialog-padding-spacing-polish]]).
