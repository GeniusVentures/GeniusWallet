---
sketch: 069
name: sdk-accounts-section
question: "The SDK section is one navbar chip, one drawer and five dialogs. Its footer CTAs truncate to 'Add with mn…' at the panel's real width, its row actions are split across two affordances depending on row state, and one dialog never went through GWDialog. What is the shape of the whole section on today's components?"
winner: "A \u00b7 One door - chosen by Jakub 2026-07-28 after a verification pass. BUILT in quick 260728-s9k, together with four bug fixes the sketch did not have: a false delete-success, a bloc result read one frame early, a silent seed-phrase copy, and no payout validation."
tags: [drawers, sdk-accounts, dialogs, cta, menus, security, flow, follows-068, follows-156]
lane: execution
---

# Sketch 069: The SDK Accounts section, end to end

Jakub, 2026-07-28, from a live walk: *"góra wygląda w porządku ale CTA do poprawy [...] oraz po
trzech kropkach ten pop-up i dalsze jego opcje, przeanalizuj flow i dostosuj wszystkie ekrany z tej
sekcji"*.

The top of the drawer is the 068-A work from an hour earlier and it holds. This is everything below
and behind it: the footer, the row menu, and the five dialogs the menu and the footer open.

## How to view

```
open .planning/sketches/069-sdk-accounts-section/index.html
```

Four variants × six screens - drawer, row menu, add-account, payout, delete, recovery QR - each at
real size, dark/light. The component table beside the panel changes with the variant.

## Findings from the code

**1 · The footer CTAs cannot fit, and nothing in the code can tell.** Two `Expanded` `GWButton`s in a
420px panel: 420 − 40 padding − 8 gap = **186px each**, and *"Add with private key"* plus a 20px
leading icon needs roughly 210. Flutter ellipsizes silently, so the shipped drawer reads *"Add with
mn…"* / *"Add with priv…"*. Nothing is misconfigured - the layout asks for more room than exists.

**2 · "Copy mnemonic" writes a seed phrase to the clipboard with no confirmation and no feedback.**
The entire handler is `onPressed: () => {Clipboard.setData(ClipboardData(text: mnemonic))}`. No
warning before, no snackbar after. Every other copy in the app confirms - the wallet drawer says
*"Address copied to clipboard"* - and this is the one value where a silent clipboard write is a
security event rather than a convenience.

**3 · Row actions are split by state across two affordances.** The **selected** row gets a ⋮ menu
with three items; every **other** row gets a bare red delete `IconButton` and no menu. So Delete is
never in the menu, the menu never appears on a row you can delete, and the code's own guard
(*"Cannot delete the currently selected SDK account"*) **can never fire from the UI** - the button it
guards is not rendered on that row.

**4 · The payout-address result is read one frame too early.**
`context.read<AppBloc>().add(SetSDKPayoutAddress(...))` is followed immediately by
`state.setPayoutAddressResult`. A bloc processes events asynchronously, so the snackbar reports the
**previous** attempt's result; on the first call after a fresh start it reports `null`
(*"Failed to set payout address: null"*). This is a real bug and it is independent of every variant
here.

**5 · The recovery-QR dialog is the only one outside `GWDialog`** - a raw `AlertDialog` with a stock
`TextButton`. Its white QR backdrop is deliberate and stays (QR codes need it to scan); the shell
around it should be the component.

**6 · The payout field has no validation.** It accepts any string and posts it. The app already knows
what an address looks like.

## Variants

| | Variant | Footer | Where the method is chosen | Cost |
|---|---|---|---|---|
| **A** ★ | **One door** | one gradient *Add account*, full width | inside the dialog, as a segmented control | one extra control in the dialog |
| **B** | **Stacked** | two full-width buttons, stacked | in the footer, as today | two equal-weight CTAs, 88px of footer |
| **C** | **Menu-first** | one gradient *Add account*, full width | an anchored menu before the dialog | an extra click on every add |

**All three unify the row menu, and that is not a variant choice - it is finding 3.** Every row gets
the same ⋮ with the same four items in the same order; what does not apply is **disabled, not
absent**. The menu stops changing shape under you, Delete stops being a red button that exists on
some rows, and the guard the code already has finally becomes visible as a disabled item.

## Recommendation

**★ A · One door.** The footer stops competing with itself, the label fits at full size, and both add
paths collapse into one dialog - so the warning, the validation and the copy are written once instead
of twice. The method switch is the app's existing control-track recipe (`surfaceSunken` + hairline +
pill radius, the segmented "baton" from `CONVENTIONS.md`), so the dialog gains a **pattern**, not a
widget.

**Runner-up: B · Stacked.** The honest minimum, and the right answer if the section should not be
touched beyond the defect: nothing truncates, both paths stay one click away, no dialog changes. It
costs 88px of footer and leaves two equal-weight CTAs above the footer rule - the shape both the
receipt and Swap Settings deliberately avoid, which is the only reason it is not the pick.

**Rejected: C · Menu-first.** Same footer as A with no dialog change, but every add becomes two
clicks before you can type, and a two-item menu is a heavy way to ask a binary question. A segmented
control asks it in the place the answer is needed.

## What A adds that is genuinely new, and why

One thing in A is not an existing component: **a warn-tinted note row** above the fields that handle
key material (`statusWarning` at ~10% on a 28% hairline). It is proposed for exactly three places -
the recovery-phrase field, the recovery QR, and the delete confirmation - all of which are
irreversible or hand over control of an account.

**If that does not earn its keep, drop it and the variant still stands.** The footer, the unified
menu and the shared dialog are the substance; the warning row is the one piece that should be argued
rather than assumed.

## What this does NOT propose

- No change to the SDK bloc events, the native calls, or the QR library.
- No change to the navbar chip (it self-hides with no accounts, which is correct).
- The white QR backdrop stays - it is mode-invariant on purpose and required for scanning.
- Finding 4 (the early bloc read) is a **bug fix that should ride with whichever variant wins**, not
  a design decision.

## MANIFEST row

```
| 069 | sdk-accounts-section | The SDK section is 1 navbar chip, 1 drawer and 5 dialogs; its footer CTAs truncate to "Add with mn…" at the panel's real width, its row actions are split across two affordances by row state, and one dialog never went through GWDialog. What is the shape of the whole section on today's components? | **Recommended A · One door** - one gradient `Add account` CTA, method chosen inside the dialog via the control-track segmented recipe, so both add paths share one dialog/warning/validation; runner-up B · Stacked (honest minimum, nothing truncates, but 2 equal-weight CTAs and 88px of footer); rejected C · Menu-first (two clicks before you can type to answer a binary question). **All three unify the row menu - not a variant choice**: one ⋮ on every row, same 4 items, same order, inapplicable ones DISABLED not absent. **Findings: the footer CTAs cannot fit** (186px each vs ~210 needed - Flutter ellipsizes silently); **"Copy mnemonic" writes a seed phrase to the clipboard with no warning and no confirmation**, where every other copy in the app confirms; **row actions split by state** so Delete is never in the menu and the code's own "cannot delete the active account" guard can never fire from the UI; **the payout result is read one frame too early** (`add()` then immediate `state.…` on a bloc - reports the PREVIOUS attempt, or `null` on first run) - a real bug, independent of the variants; the QR dialog is the only one outside `GWDialog`; the payout field has no validation. | drawers, sdk-accounts, dialogs, cta, menus, security, flow, follows-068, follows-156 |
```

## BUILT 2026-07-28 - quick 260728-s9k

Jakub verified the sketch against the code before approving it, and that pass produced **a seventh
finding this sketch did not have**: `_confirmDeleteSDKAccount` showed *"SDK account deleted"*
unconditionally, one line after dispatching, checking nothing - while `_onDeleteSDKAccount` emits
only on `GENIUS_NODE_RET_OK` with **no else**. A refused delete was silent at both layers and the
user was told it had worked. That is worse than finding 4 and was fixed with it.

Two things the sketch drew that the code corrected:

- **The menu items are gated on more than selection.** `Copy mnemonic` and `Show recovery QR` also
  need `getSelectedAccountMnemonic() != null`, because a private-key import has no phrase. The
  sketch drew them always present on the active row.
- **The drawer's empty state is unreachable** - the navbar chip self-hides at zero accounts and you
  cannot reach zero, since the last remaining account is the selected one and the SDK refuses to
  delete it. Not a gap in the sketch; dead code in the app.

The warning row A proposed was kept, at two call sites (recovery-phrase field, recovery QR) and not
on the delete dialog, where the copy already says it in words.
