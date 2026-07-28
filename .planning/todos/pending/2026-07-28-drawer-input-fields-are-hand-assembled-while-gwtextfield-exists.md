# Drawer input fields are hand-assembled, while GWTextField already does the job

**Found:** 2026-07-28, during quick 260728-q7c, when Jakub asked whether the `Custom value` label
came from a component. It did not. Neither does most of the field around it.
**Type:** component drift. No user-visible defect - the drawers look and behave correctly today.
**Deferred deliberately:** see "Why this is not urgent" at the bottom.

## What the app already has

| | what it is |
|---|---|
| `GWTextField` (`components/inputs/gw_text_field.dart`) | the whole package: label above (`labelMd`/`textSecondary`/`space4`), box, fill, four border states, `helper`/`errorText` line |
| `GWSearchField` (same file) | `GWTextField` dressed as a search box, with a gradient ring on focus |
| `GWFocusRing` (`components/inputs/gw_focus_ring.dart`) | the standalone gradient ring |

## What the drawers do instead

Both drawer fields are assembled from parts - `GWFocusRing` + a raw Material `TextField` + a
hand-written label + (in Swap Settings) a hand-written message row:

- `lib/squid_router/swap_settings_drawer.dart` - the slippage field
- `lib/squid_router/token_selector_drawer.dart` - the token search, which is **literally a search
  field**; `design_gallery_screen.dart:531` even displays `GWSearchField(hint: 'Search tokens')` as
  the component for exactly this

## The one line that forces it

`GWTextField` hardcodes its fill:

```dart
filled: true,
fillColor: gw.surfaceElevated,   // no parameter, no override
```

That was harmless until 2026-07-28. Two things broke it on the same day:

1. **156-A made the drawer panel `surfaceElevated`.** A field using the component inside a drawer
   would now be painted its own background's colour - 1.00:1, invisible.
2. **Jakub asked for the field to be recessed** (`surfaceSunken`, live walk). The component cannot
   express that at all.

## The label role, counted

`GWTextField` renders it as `labelMd` / `textSecondary`, then `space4`. **Three files hand-copy those
exact two values**, all because they wrap `GWFocusRing` and so cannot use the component:

- `swap_field.dart:87` - "You Pay" / "You Receive"
- `submit_logs_screen.dart:541` - "Message" (its own comment names `GWTextField` as the standard)
- `swap_settings_drawer.dart` - "Custom value" (added 2026-07-28; **first written as a fourth value**,
  13/w500/`textPrimary70` from sketch 067's mockup, corrected the same day)

Separately, `token_info_screen.dart:561` and `custom_drop_down.dart:36` use `labelText:`, i.e. the
floating notched Material label - a different pattern again. `submit_logs_screen.dart`'s comment
claims it was "the one place in the app that reads that way"; there are two.

## The finding that makes this bigger than one parameter

**`GWSearchField` does not use `GWFocusRing`.** It builds its own gradient ring out of an
`AnimatedContainer` (`gw_text_field.dart:303-315`). So the app carries **two implementations of
"brand gradient ring on focus"**: the component, used by the swap amount field, the slippage field,
the token search and the feedback message; and `GWSearchField`'s private one.

Its resting edge is hardcoded `gw.borderSubtle` too - **1.36:1 on the 156-A drawer panel**, which is
precisely the 1.4.11 defect quick 260728-q7c just fixed with `borderControl` (3.30:1). So migrating
the token search to `GWSearchField` as it stands would reintroduce the defect.

## What the work actually is

| step | cost | verdict |
|---|---|---|
| ~~add an optional `fill` to `GWTextField`~~ | one parameter | **DONE 2026-07-28** - quick 260728-s9k, when Jakub pointed at a dialog field painted its own dialog's colour |
| add an optional resting-edge colour to `GWSearchField` | one parameter | cheap |
| token search → `GWSearchField` | deletes ~35 hand-rolled lines | **the real win** |
| slippage field → `GWTextField` | the component would have to grow an ICON and a THIRD message tone (`_Message` is 13/`labelMd`/3 tones with `info_outline`; `GWTextField`'s helper is 14/`bodySm`/2 tones, no icon) to serve ONE consumer | **do not** |
| reconcile `GWSearchField` onto `GWFocusRing` | removes the duplicate ring | worth doing with the above |

## Why this is not urgent

Recommended deferral, agreed with Jakub 2026-07-28:

- **Nothing is broken for a user.** The drawers look and behave correctly; this is internal tidiness.
- **Done honestly it stops being a drawer change.** `GWTextField` / `GWSearchField` are used by
  Settings, News, Markets, the account manager and onboarding - so the blast radius is the app, and
  it would have been started in the middle of a drawer walk.
- **The payoff is two call sites.** A component that serves two consumers rarely repays its cost;
  the honest version of this task is the ring reconciliation, which serves five.

## Related

- `.planning/quick/260728-q7c-drawer-card-canvas-and-section-kicker/260728-q7c-SUMMARY.md` - where
  the fill and edge values came from, and why the field is recessed rather than raised
- `.planning/sketches/065-kicker-component/README.md` - the same shape of problem solved for the
  uppercase label: five hand-written copies, one component, a static style for the call sites that
  needed the type but not the widget. That escape hatch (`GWKicker.style`) is likely the pattern
  here too, for the three label copies that cannot take the widget.

---

## Partially addressed 2026-07-28 (quick 260728-s9k)

Jakub, pointing at the Add-account dialog: *"tu powinien być użyty gradient obramówka komponent
znajdź i zaaplikuj"* - and then the same for the private-key field.

The component was `GWFocusRing`, and the reason it was not being used is now written down in
`GWTextField` itself: **a `BorderSide` takes a single `Color`, so no `InputBorder` can be a
gradient.** `GWTextField`'s `focusedBorder` was therefore a flat `brandPrimaryStrong` stroke - the
one thing `drawers-final`'s global rule forbids, in the single state where the app is most clearly
speaking to the user.

Two parameters landed, both predicted by this file:

- **`fill`** - the hardcoded `surfaceElevated` this note opened with.
- **`focusRing`** - wraps the input in `GWFocusRing`, and implies `borderless` so the
  `InputDecoration` cannot draw a second border inside the ring (the exact bug `GWFocusRing`'s doc
  warns about: `theme.dart`'s app-wide `focusedBorder` beats a local `border: InputBorder.none`).

**`focusRing` is OPT-IN, and that is a compromise rather than a design.** All eight call sites
arguably want it; flipping the default re-skins Settings, News, Markets, the account manager and
onboarding in one go, which deserves its own walk. Until then **two fields in the app light a
gradient on focus and six light a flat blue** - the ceiling is recorded on the flag itself.

**What remains from the original note:** `GWSearchField` still hand-rolls its own gradient ring
instead of using `GWFocusRing`, so the app still carries two implementations of one idea; the token
search and the slippage field are still assembled from parts rather than being `GWTextField`; and
the label role is still hand-copied in three files.
