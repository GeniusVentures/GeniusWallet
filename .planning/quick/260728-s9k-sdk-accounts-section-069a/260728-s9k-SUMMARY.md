---
quick_id: 260728-s9k
status: complete
date: 2026-07-28
sketch: 069-A
commit: none - CLAUDE.md forbids commits
files_modified:
  - lib/account/sdk_account_manager.dart
  - lib/account/account_dropdown_selector.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - lib/theme/theme.dart
  - lib/components/inputs/gw_text_field.dart
  - lib/components/feedback/gw_warning_note.dart
  - lib/components/qr/crypto_address_qr.dart
  - test/account/sdk_row_actions_test.dart
  - .planning/todos/pending/2026-07-28-five-private-segmented-controls-one-documented-recipe.md
gates:
  analyze_lib: 59
  analyze_baseline: 59
  flutter_test: 348 pass / 1 fail
  flutter_test_baseline: 342 pass / 1 fail
verification: hot-reloaded live; HUMAN WALK PENDING
---

# Quick 260728-s9k - SUMMARY

Sketch **069-A "One door"**, plus four bugs the verification pass turned up.

## The design work

**One CTA instead of two that could not fit.** Two `Expanded` `GWButton`s in a 420px panel get
420 − 40 − 8 = **186px each**, and *"Add with private key"* plus a 20px icon needs ~210, so both
labels were silently ellipsized to *"Add with mn…"* / *"Add with priv…"*. Now one
`GWButton(gradient, lg, expand)` labelled **Add account**.

**Both add dialogs merged into one.** They differed in a hint string and which bloc event they
fired, and each carried **its own copy of the IME hardening flags** - the four that keep key
material out of the keyboard's learning store. One dialog means one place to get that right, which
is most of why merging was worth doing rather than just relabelling.

The method switch is a segmented control built to `CONVENTIONS.md`'s Control track recipe. Switching
method **clears the field**: a mnemonic left in the box while the label says "Private key" is exactly
what gets pasted into the wrong import.

**One menu on every row.** Four items, one order, inapplicable ones **disabled rather than absent**.
Before, the selected row got a three-item menu and every other row got a bare red delete
`IconButton` and no menu - so Delete was never in the menu, the menu never appeared on a row you
could delete, and the code's own guard could never fire because the button it guarded was not
rendered there. That guard is now a disabled item, which is where a rule belongs.

**The QR dialog moved onto `GWDialog`** - it was the last raw `AlertDialog` in the section. Its white
backdrop stays and stays mode-invariant: a QR needs a light quiet zone to scan.

## Four bugs, none of them design

**A false success.** `_confirmDeleteSDKAccount` showed *"SDK account deleted"* unconditionally, one
line after dispatching, checking nothing - and `_onDeleteSDKAccount` emits only on
`GENIUS_NODE_RET_OK` **with no else**, so a refusal was silent at both layers. A refused delete told
the user it had worked.

The bloc exposes no error for this, so the fix takes the observable truth: await the stream until
the address leaves `sdkAccounts`, with a timeout that IS the refusal case. The message now says
*"The SDK refused to delete that account."* when nothing happened.

**A result read one frame early.** `_showSetPayoutAddressDialog` read
`state.setPayoutAddressResult` synchronously after `add(...)`. A bloc is asynchronous, so it reported
the **previous** attempt - or `"Failed to set payout address: null"` on the first call after a fresh
start. It awaits the next state now.

**A silent seed-phrase copy.** `Copy mnemonic` was `onPressed: () => {Clipboard.setData(...)}` and
nothing else. It confirms first and reports after, like every other copy in the app - except this is
the one value where a silent clipboard write is a security event rather than a convenience.

**No payout validation.** The field posted any string to a native SDK call. `isEvmAddress` is a
42-character `0x` hex test, live rather than on-submit. Deliberately **not** a checksum test: the SDK
does that, and rejecting a valid lowercase address for not being EIP-55 cased would be worse than
the no-validation it replaces.

## The check, and why it is a pure function

The menu's gating is four booleans, two of which are security rules rather than tidiness:
`GeniusSDKGetMnemonic` returns the **selected** account's phrase, so offering Copy or QR on any other
row would put one account's recovery phrase under a different account's address; and a private-key
import has no phrase at all, so "has a mnemonic" is a different question from "is selected".

Both are one boolean away from being wrong and **neither would look wrong on screen** - the menu
would simply have an extra enabled item. So the rules were lifted out of the widget into
`sdkRowActions({isSelected, hasMnemonic})` and pinned across all four combinations, plus a case
asserting no row ends up with a dead menu. `isEvmAddress` is tested on the shapes the field used to
forward untouched - including one character short, which is the failure a human eye does not catch.

## Component honesty

Everything used exists except the segmented switch, which is a **recipe** in `CONVENTIONS.md` with
**five private implementations** (two identical `_TimeframeSegment`s, the transactions filter track,
`_PresetChip`, and now this). Built inline to the recipe and a todo filed: building
`GWSegmentedControl` here would ship a component with one consumer, failing the promotion test 065,
068 and 154 were each held to.

The warn row is new and private, used in exactly two places (the recovery-phrase field, the recovery
QR). Not on the delete dialog - the copy there already says it in words.

## Gates

- `flutter analyze lib` = **59**, baseline 59. Three `use_build_context_synchronously` ignores, each
  sitting on the `navigator.context` argument it excuses: that context belongs to the ROOT navigator
  and outlives the popped drawer, which the analyzer cannot see.
- `flutter test` = **348 / 1**, baseline 342/1. The failure is the inherited
  `local_wallet_storage_test.dart` (no `main()`).
- Hot-reloaded live. **No commit** - `CLAUDE.md`.

## Follow-up

- **Walk it**: the single CTA, the merged dialog and its switch, the menu on an active row and on a
  non-active one, and a delete.
- The drawer's **empty state is unreachable**: the navbar chip self-hides at zero accounts, and you
  cannot reach zero because the last remaining account is the selected one and the SDK refuses to
  delete it. Left in place as a defensive branch; noted so nobody spends time designing it.

## Walk audit, same day - the menus and the CTA heights

Jakub: *"sprawdź ten dropdown czy tam font i reszta się zgadza [...] sprawdź też CTA height czy się
zgadza w tych drawerach accountowych"*. Five findings, all confirmed in code before touching
anything.

### The menu labels were not in the app's font

`MenuItemButton` renders its child in `textTheme.labelLarge`, and
`GeniusWalletTypography.toMaterialTextTheme()` **does not map `labelLarge`** - it fills 10 of
Material's 15 slots. `ThemeData` merges over the platform default, and nothing sets a global
`fontFamily`, so every menu row in the app was drawing in **Roboto 14/w500/0.1** beside Inter
everywhere else. Close enough to read as "off" without being nameable, which is why it lasted.

Fixed with a new `menuButtonTheme` carrying `bodySm`, **not** by mapping `labelLarge` globally: that
slot also drives every bare text button and `SnackBarAction`, so re-typing it app-wide is its own
decision. Todo filed with the full list of five unmapped slots.

### A comment was justifying duplicated code on a false premise

Both menus carried: *"the reconciled theme no longer supplies menuTheme, so an un-styled MenuAnchor
container reverts to stock Material 3"*. `theme.dart:405` **has always supplied one** - and its own
comment says it was kept *for exactly these two menus*. So two files hand-rolled a `MenuStyle` the
file below them already provided. Both local styles deleted; the container's fill moved into
`menuTheme` with `surfaceTintColor: transparent` so M3 cannot tint the menu's colour away from the
token.

### A disabled item disagreed with its own icon

`MenuItemButton` disables the foreground it owns, but `leadingIcon` is a widget we hand it - so a
disabled **Delete account** rendered a greyed label beside a **full-strength red trash glyph**,
visible in Jakub's screenshot. The icon is dimmed at the source now, and
`disabledForegroundColor` is pinned so Material does not substitute its own 38% for the label and
re-open the same gap from the other side.

### The receipt's CTA was the odd one out

Footer button heights across the drawers, measured from `GWButton._height`:

| | height |
|---|---|
| Swap Settings `Apply`, Your Accounts `Add Wallet`, SDK `Add account` - all `GWButtonSize.lg` | **56** |
| Transaction receipt `View on Explorer` - **no `size:` passed**, so the `md` default | **48** |
| Swap success / fail - raw `OutlinedButton` with a hand-typed `Size.fromHeight(48)` | 48 |
| reown ×3, Banxa ×2 - raw `OutlinedButton`, no minimum at all | Material's **40** |

The receipt now passes `lg`. **The seven raw `OutlinedButton` footers are NOT fixed here** - that is
sketch 066's archetype work (it already found them: *"seven of the fourteen have footers entirely
outside the design system"*), and doing it inside an SDK-drawer task would be scope theft. Recorded
so the three-height spread is a known number rather than a surprise.

### One unit, two spellings, adjacent

`GeniusBalanceDisplay` hard-codes its suffix as the abbreviation **"min"**, so the wallet list read
*"0 min"* directly above *"0.0 minions"* - the two branches of the same row builder. The suffix is
written at the call site now so both say the same word.

### The dialog fields lit a flat blue, not the gradient

*"tu powinien być użyty gradient obramówka komponent"*, and then the same for the private-key field.

The component is `GWFocusRing`, and the reason it was not in use turns out to be structural rather
than an oversight: **a `BorderSide` takes a single `Color`, so no `InputBorder` can be a gradient** -
which is why `GWFocusRing` exists at all. `GWTextField`'s `focusedBorder` was a flat
`brandPrimaryStrong` stroke, the one thing the app's accent rule forbids, in the state where the app
is most clearly speaking to the user.

`GWTextField` gained two parameters, both of which the 2026-07-28 field-drift todo had already
predicted:

- **`focusRing`** - wraps the input in `GWFocusRing` and implies `borderless`, so the
  `InputDecoration` cannot paint a second border inside the ring. That coupling is not tidiness:
  `theme.dart`'s app-wide `focusedBorder` beats a local `border: InputBorder.none`, because a
  per-state border always beats the fallback.
- **`fill`** - the hardcoded `surfaceElevated` that made a dialog field the same colour as its own
  dialog. All three SDK fields take `surfaceSunken`, the same call the drawer fields took.

**`focusRing` is opt-in and the flag says why on itself:** all eight `GWTextField` call sites
arguably want it, but flipping the default re-skins Settings, News, Markets, the account manager and
onboarding in one commit. Until that walk happens, two fields in the app light a gradient and six
light a flat blue - recorded as a `ponytail:` ceiling with the upgrade path, not left to be
rediscovered.

### Walk round 3 - four more, and one component promoted

**The error message could not say what was wrong.** `InputDecoration` ellipsizes an error at one
line by default, so *"That is not a complete address - 42 characters starting with 0x."* arrived as
*"…42 characters s…"*. `errorMaxLines: 2` plus shorter copy.

**And it was rendering inside the gradient ring.** With `focusRing` on, the whole `TextFormField` -
including the error/helper area the `InputDecoration` draws - sat inside `GWFocusRing`, so the
refusal read as part of the field. The message moves BELOW the ring, and `errorText`/`helperText`
are suppressed in the decoration so it cannot be drawn twice.

**The ring lit brand-green over a red error.** `enabled: enabled && !invalid` now, so an invalid
value keeps the refusal colour even while focused - the same rule the slippage field states: the
gradient says "you are here", the red says "this will not apply", and the second outranks the first.

**The QR was built the way the app had already stopped building QRs.** It was a
`SizedBox(width: GeniusBreakpoints.small * 0.5)` - a **breakpoint constant used as a pixel width** -
wrapping a white `Container` wrapping an unsized `QrImageView`. `crypto_address_qr.dart` records
having fixed exactly that once already (*"self-contained so it no longer depends on the caller's
wrapping SizedBox"*). Now `QrImageView(size: 190, backgroundColor: Colors.white)`, matching the
component. The white stays mode-invariant in both files: a camera needs a light quiet zone.

**The delete dialog spaced itself by hand.** `'…?\n\n' 'This action cannot be undone.'` - a typed
double break inside the message string, producing a gap wider than any of `GWDialog`'s own
(`space4` title→message, `space8` →content, `space10` →actions). That is why the dialog read as
spaced differently from every other one. Two sentences, one paragraph, component does the spacing.

### `GWWarningNote` - promoted on its third consumer

The amber note existed twice: `crypto_address_qr.dart`'s network-mismatch note (sketch 034-A2) and
the `_KeyMaterialWarning` written earlier in this task. With the recovery QR that is three.

**The colour is why it deserves to be a component rather than a Row.**
`GeniusWalletColors.statusWarning` (#FFC42E) is a FILL-tuned token - about 13:1 on the dark canvas
and roughly **1.6:1 on white**, so as an icon or a border on a light surface it is not there.
`crypto_address_qr.dart` hit that first and worked out a darkened amber at ~7.1:1. **The version
written earlier in this task did not**, and would have failed in light mode - a defect introduced and
removed inside the same task, only because the older consumer had written its reasoning down.

The component took the shipped consumer's values **verbatim** (no fill, border at 50%, `radiusMd`,
`space6`/`space4`), so migrating it moves nothing on screen. That is the point: a promotion should
not be a redesign.
